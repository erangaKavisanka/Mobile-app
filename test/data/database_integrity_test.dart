import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:ecolink/data/database/app_database.dart';
import 'package:ecolink/features/devices/domain/node.dart';
import 'package:ecolink/features/messaging/domain/message.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:ecolink/features/synchronization/domain/sync_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late AppDatabase db;
  setUp(() {
    env = TestEnv();
    db = env.db;
  });
  tearDown(() => env.dispose());

  Future<void> insertNode(String id, String nodeId) => db
      .into(db.nodes)
      .insert(
        NodesCompanion.insert(
          id: id,
          nodeId: nodeId,
          name: nodeId,
          role: NodeRole.traveller,
          status: NodeStatus.unknown,
        ),
      );

  Future<void> insertConversation(String id, String peer) => db
      .into(db.conversations)
      .insert(
        ConversationsCompanion.insert(
          id: id,
          peerNodeId: peer,
          title: peer,
          createdAt: DateTime.now(),
        ),
      );

  Message message(String id, String conversationId) => Message(
    id: id,
    conversationId: conversationId,
    senderNodeId: 'a',
    recipientNodeId: 'b',
    body: 'x',
    direction: MessageDirection.outgoing,
    status: MessageStatus.queued,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('constraints', () {
    test('node, user and conversation identities are unique', () async {
      await insertNode('n1', 'NODE-1');
      await expectLater(insertNode('n2', 'NODE-1'), throwsA(anything));

      await insertConversation('c1', 'NODE-1');
      await expectLater(insertConversation('c2', 'NODE-1'), throwsA(anything));

      await env.users.ensureLocalUser();
      final user = await db.select(db.users).getSingle();
      await expectLater(
        db
            .into(db.users)
            .insert(
              UsersCompanion.insert(
                id: 'other',
                displayName: 'Dup',
                nodeId: user.nodeId,
                createdAt: DateTime.now(),
              ),
            ),
        throwsA(anything),
      );
    });

    test('a conversation must reference an existing node', () async {
      await expectLater(insertConversation('c1', 'GHOST'), throwsA(anything));
    });

    test('a node with conversations cannot be deleted', () async {
      await insertNode('n1', 'NODE-1');
      await insertConversation('c1', 'NODE-1');
      await expectLater(
        (db.delete(db.nodes)..where((t) => t.id.equals('n1'))).go(),
        throwsA(anything),
      );
      expect(await db.select(db.nodes).get(), hasLength(1));
    });

    test('deleting a conversation removes its messages', () async {
      await insertNode('n1', 'NODE-1');
      await insertConversation('c1', 'NODE-1');
      await env.messages.insertMessage(message('m1', 'c1'));
      await env.messages.insertMessage(message('m2', 'c1'));
      await (db.delete(db.conversations)..where((t) => t.id.equals('c1'))).go();
      expect(await db.select(db.messages).get(), isEmpty);
    });

    test('deleting a node keeps its device logs but detaches them', () async {
      await insertNode('n1', 'NODE-1');
      await env.nodes.log('seen', nodeRowId: 'n1');
      await (db.delete(db.nodes)..where((t) => t.id.equals('n1'))).go();
      final log = await db.select(db.deviceLogs).getSingle();
      expect(log.nodeId, isNull);
      expect(log.message, 'seen');
    });

    test('a log cannot reference a node that does not exist', () async {
      await expectLater(
        env.nodes.log('x', nodeRowId: 'ghost'),
        throwsA(anything),
      );
    });
  });

  group('transactions', () {
    test(
      'a message and its sync entry are written together or not at all',
      () async {
        await insertNode('n1', 'NODE-1');
        await insertConversation('c1', 'NODE-1');
        await expectLater(
          db.transaction(() async {
            await env.messages.insertMessage(
              message('m1', 'c1'),
              enqueueSync: true,
            );
            throw StateError('crash before commit');
          }),
          throwsStateError,
        );
        expect(await db.select(db.messages).get(), isEmpty);
        expect(await db.select(db.syncQueue).get(), isEmpty);
      },
    );

    test('a committed message always has exactly one sync entry', () async {
      await insertNode('n1', 'NODE-1');
      await insertConversation('c1', 'NODE-1');
      expect(
        await env.messages.insertMessage(
          message('m1', 'c1'),
          enqueueSync: true,
        ),
        isTrue,
      );
      expect(
        await env.messages.insertMessage(
          message('m1', 'c1'),
          enqueueSync: true,
        ),
        isFalse,
      );
      final rows = await db.select(db.syncQueue).get();
      expect(rows.map((r) => r.entityId), ['m1']);
    });

    test('a duplicate insert does not bump unread counters', () async {
      await insertNode('n1', 'NODE-1');
      await insertConversation('c1', 'NODE-1');
      final incoming = Message(
        id: 'in-1',
        conversationId: 'c1',
        senderNodeId: 'NODE-1',
        recipientNodeId: 'me',
        body: 'hi',
        direction: MessageDirection.incoming,
        status: MessageStatus.delivered,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await env.messages.insertMessage(incoming);
      await env.messages.insertMessage(incoming);
      final conv = await db.select(db.conversations).getSingle();
      expect(conv.unreadCount, 1);
    });

    test(
      'getOrCreateConversation is idempotent and creates the node once',
      () async {
        final a = await env.messages.getOrCreateConversation('PEER-9');
        final b = await env.messages.getOrCreateConversation('PEER-9');
        expect(a.id, b.id);
        expect(await db.select(db.conversations).get(), hasLength(1));
        expect(await db.select(db.nodes).get(), hasLength(1));
      },
    );

    test('clearAllData is atomic and leaves the local identity', () async {
      final user = await env.users.ensureLocalUser();
      await env.messaging.send(peerNodeId: 'PEER-9', body: 'x');
      await env.sos.trigger();
      await db.clearAllData();
      for (final count in [
        (await db.select(db.messages).get()).length,
        (await db.select(db.conversations).get()).length,
        (await db.select(db.nodes).get()).length,
        (await db.select(db.sosEvents).get()).length,
        (await db.select(db.syncQueue).get()).length,
        (await db.select(db.deviceLogs).get()).length,
        (await db.select(db.appSettings).get()).length,
      ]) {
        expect(count, 0);
      }
      expect((await env.users.ensureLocalUser()).nodeId, user.nodeId);
    });
  });

  group('SOS transitions', () {
    Future<void> create(String id) => env.sosRepo.create(
      SosEvent(
        id: id,
        sourceNodeId: 'me',
        status: SosStatus.triggered,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    test('failed is reachable only before acknowledgement', () async {
      await create('a');
      await env.sosRepo.advance('a', SosStatus.sentToGateway);
      await env.sosRepo.advance('a', SosStatus.failed);
      expect((await env.sosRepo.get('a'))!.status, SosStatus.failed);

      await env.sosRepo.advance('a', SosStatus.sentToGateway); // retry
      await env.sosRepo.advance('a', SosStatus.acknowledged);
      await env.sosRepo.advance('a', SosStatus.failed); // too late
      expect((await env.sosRepo.get('a'))!.status, SosStatus.acknowledged);
    });

    test('a closed SOS stays closed', () async {
      await create('b');
      await env.sosRepo.advance('b', SosStatus.failed);
      await env.sosRepo.advance('b', SosStatus.cancelled);
      await env.sosRepo.advance('b', SosStatus.failed);
      await env.sosRepo.advance('b', SosStatus.sentToGateway);
      expect((await env.sosRepo.get('b'))!.status, SosStatus.cancelled);
    });

    test('every status change queues one update for the cloud', () async {
      await create('c');
      await env.sosRepo.advance('c', SosStatus.sentToGateway);
      await env.sosRepo.advance('c', SosStatus.acknowledged);
      final rows = await db.select(db.syncQueue).get();
      expect(rows.map((r) => r.operation).toSet(), {
        SyncOperation.create,
        SyncOperation.update,
      });
      expect(rows, hasLength(2)); // updates collapse into one queued snapshot
      final update = rows.firstWhere(
        (r) => r.operation == SyncOperation.update,
      );
      expect(update.payload, contains('acknowledged'));
    });
  });

  group('persistence and migration', () {
    late Directory dir;
    late File file;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('ecolink_db_');
      file = File('${dir.path}/ecolink.sqlite');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('data and schema version survive closing and reopening', () async {
      var first = AppDatabase(NativeDatabase(file));
      await first
          .into(first.nodes)
          .insert(
            NodesCompanion.insert(
              id: 'n1',
              nodeId: 'NODE-1',
              name: 'One',
              role: NodeRole.relay,
              status: NodeStatus.online,
              batteryPercent: const Value(42),
            ),
          );
      final version =
          (await first.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version');
      expect(version, first.schemaVersion);
      await first.close();

      first = AppDatabase(NativeDatabase(file));
      final node = await first.select(first.nodes).getSingle();
      expect(
        (node.nodeId, node.batteryPercent, node.role),
        ('NODE-1', 42, NodeRole.relay),
      );
      // Foreign keys are re-enabled on every open, not just the first.
      await expectLater(
        first
            .into(first.conversations)
            .insert(
              ConversationsCompanion.insert(
                id: 'c',
                peerNodeId: 'GHOST',
                title: 't',
                createdAt: DateTime.now(),
              ),
            ),
        throwsA(anything),
      );
      await first.close();
    });

    test(
      'opening a database written by a newer app is refused, not corrupted',
      () async {
        final newer = AppDatabase(NativeDatabase(file));
        await newer.customStatement('PRAGMA user_version = 99');
        await newer.close();

        final old = AppDatabase(NativeDatabase(file));
        await expectLater(
          old.select(old.nodes).get(),
          throwsA(predicate((e) => e.toString().contains('Cannot downgrade'))),
        );
        await old.close();
      },
    );
  });
}
