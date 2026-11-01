import 'package:drift/drift.dart' hide isNotNull;
import 'package:ecolink/data/database/app_database.dart';
import 'package:ecolink/features/devices/domain/node.dart';
import 'package:ecolink/features/messaging/domain/message.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:ecolink/features/synchronization/domain/sync_item.dart';
import 'package:ecolink/data/repositories/sync_queue_writer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_env.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  test('creates schema and enforces foreign keys', () async {
    final insertOrphan = db
        .into(db.messages)
        .insert(
          MessagesCompanion.insert(
            id: 'm1',
            conversationId: 'missing',
            senderNodeId: 'a',
            recipientNodeId: 'b',
            body: 'hi',
            direction: MessageDirection.outgoing,
            status: MessageStatus.local,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    await expectLater(insertOrphan, throwsA(anything));
  });

  test('stores timestamps with millisecond precision', () async {
    final t = DateTime.utc(2026, 1, 2, 3, 4, 5, 678);
    await db
        .into(db.locationRecords)
        .insert(
          LocationRecordsCompanion.insert(
            id: 'l1',
            latitude: 1,
            longitude: 2,
            recordedAt: t,
          ),
        );
    final row = await db.select(db.locationRecords).getSingle();
    expect(row.recordedAt.toUtc(), t);
  });

  test('sync queue enqueue is idempotent for create', () async {
    await db.enqueueSync(
      SyncEntityType.message,
      'e1',
      SyncOperation.create,
      '{}',
    );
    await db.enqueueSync(
      SyncEntityType.message,
      'e1',
      SyncOperation.create,
      '{"x":1}',
    );
    final rows = await db.select(db.syncQueue).get();
    expect(rows, hasLength(1));
    expect(rows.single.payload, '{}');
  });

  test('sync queue update replaces snapshot and resets retries', () async {
    await db.enqueueSync(
      SyncEntityType.sosEvent,
      's1',
      SyncOperation.update,
      '{"v":1}',
    );
    await (db.update(db.syncQueue)).write(
      const SyncQueueCompanion(
        status: Value(SyncStatus.failed),
        retryCount: Value(3),
      ),
    );
    await db.enqueueSync(
      SyncEntityType.sosEvent,
      's1',
      SyncOperation.update,
      '{"v":2}',
    );
    final row = await db.select(db.syncQueue).getSingle();
    expect(row.payload, '{"v":2}');
    expect(row.status, SyncStatus.pending);
    expect(row.retryCount, 0);
  });

  test('clearAllData empties every table', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    await env.users.ensureLocalUser();
    final c = await env.messages.getOrCreateConversation('PEER-1');
    await env.nodes.log('hello');
    await env.sos.trigger();
    await env.messages.insertMessage(
      Message(
        id: 'm1',
        conversationId: c.id,
        senderNodeId: 'PEER-1',
        recipientNodeId: env.localNodeId,
        body: 'x',
        direction: MessageDirection.incoming,
        status: MessageStatus.delivered,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await env.db.clearAllData();
    expect(await env.db.select(env.db.messages).get(), isEmpty);
    expect(await env.db.select(env.db.conversations).get(), isEmpty);
    expect(await env.db.select(env.db.nodes).get(), isEmpty);
    expect(await env.db.select(env.db.sosEvents).get(), isEmpty);
    expect(await env.db.select(env.db.syncQueue).get(), isEmpty);
    // The node identity survives so the phone keeps its address on the mesh.
    expect(await env.db.select(env.db.users).get(), hasLength(1));
    expect(await env.db.select(env.db.deviceLogs).get(), isEmpty);
  });

  test('node upsert keeps readings missing from partial updates', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    await env.nodes.upsert(
      nodeId: 'N1',
      batteryPercent: 70,
      rssi: -80,
      role: NodeRole.relay,
    );
    final n = await env.nodes.upsert(nodeId: 'N1', status: NodeStatus.online);
    expect(n.batteryPercent, 70);
    expect(n.rssi, -80);
    expect(n.role, NodeRole.relay);
    expect(n.status, NodeStatus.online);
  });

  test('SOS repository ignores backwards and post-close transitions', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    final now = DateTime.now();
    await env.sosRepo.create(
      SosEvent(
        id: 's1',
        sourceNodeId: 'me',
        status: SosStatus.triggered,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await env.sosRepo.advance('s1', SosStatus.propagated, nodesReached: 2);
    await env.sosRepo.advance('s1', SosStatus.acknowledged); // late ack
    expect((await env.sosRepo.get('s1'))!.status, SosStatus.propagated);
    await env.sosRepo.advance('s1', SosStatus.resolved);
    await env.sosRepo.advance('s1', SosStatus.propagated);
    final e = (await env.sosRepo.get('s1'))!;
    expect(e.status, SosStatus.resolved);
    expect(e.closedAt, isNotNull);
    expect(e.nodesReached, 2);
  });

  test('duplicate SOS ids are not inserted twice', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    final now = DateTime.now();
    final e = SosEvent(
      id: 's1',
      sourceNodeId: 'me',
      status: SosStatus.triggered,
      createdAt: now,
      updatedAt: now,
    );
    expect(await env.sosRepo.create(e), isTrue);
    expect(await env.sosRepo.create(e), isFalse);
    expect(await env.db.select(env.db.syncQueue).get(), hasLength(1));
  });
}
