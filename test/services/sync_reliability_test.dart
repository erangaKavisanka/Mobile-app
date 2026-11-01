import 'package:ecolink/core/errors/app_exception.dart';
import 'package:ecolink/data/repositories/sync_repository_impl.dart';
import 'package:ecolink/data/services/sync_service.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:ecolink/features/synchronization/domain/sync_item.dart';
import 'package:ecolink/features/synchronization/domain/sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_env.dart';

/// Gateway that records every push and can be told to fail or lose the reply.
class RecordingGateway implements CloudGateway {
  final SimulatedCloudGateway cloud = SimulatedCloudGateway(
    isInternetAvailable: () => true,
    latency: Duration.zero,
  );
  final pushed = <String>[];
  bool offline = false;

  /// Accept the upload but fail the response, as a dropped connection would.
  int loseNextResponses = 0;

  @override
  bool get isSimulated => true;

  @override
  Future<void> push(SyncItem item) async {
    pushed.add(item.idempotencyKey);
    if (offline) throw const SyncException('offline');
    await cloud.push(item);
    if (loseNextResponses > 0) {
      loseNextResponses--;
      throw const SyncException('response lost');
    }
  }
}

void main() {
  late TestEnv env;
  late DateTime now;
  late SyncRepositoryImpl queue;
  late RecordingGateway gateway;
  late SyncService service;

  setUp(() {
    env = TestEnv();
    now = DateTime.utc(2026, 1, 1, 12);
    queue = SyncRepositoryImpl(env.db, clock: () => now);
    gateway = RecordingGateway();
    service = SyncService(queue: queue, cloud: gateway);
  });
  tearDown(() => env.dispose());

  test('backoff doubles per failure and is capped at one hour', () {
    expect(SyncBackoff.delayFor(0), Duration.zero);
    expect(SyncBackoff.delayFor(1), const Duration(seconds: 30));
    expect(SyncBackoff.delayFor(2), const Duration(minutes: 1));
    expect(SyncBackoff.delayFor(3), const Duration(minutes: 2));
    expect(SyncBackoff.delayFor(50), const Duration(hours: 1));
  });

  test(
    'a failed item is not retried automatically until its backoff passes',
    () async {
      await env.sos.trigger();
      gateway.offline = true;
      expect((await service.syncNow()).failed, 1);

      now = now.add(const Duration(seconds: 29));
      expect(await queue.due(), isEmpty);
      expect((await service.syncNow()).failed, 0);
      expect(gateway.pushed, hasLength(1));

      now = now.add(const Duration(seconds: 2)); // 31 s after the failure
      expect(await queue.due(), hasLength(1));

      // Second failure doubles the wait to 60 s.
      expect((await service.syncNow()).failed, 1);
      now = now.add(const Duration(seconds: 59));
      expect(await queue.due(), isEmpty);
      now = now.add(const Duration(seconds: 2));
      expect(await queue.due(), hasLength(1));
    },
  );

  test('a manual sync bypasses backoff', () async {
    await env.sos.trigger();
    gateway.offline = true;
    await service.syncNow();
    gateway.offline = false;

    expect((await service.syncNow()).synced, 0); // still backing off
    expect((await service.syncNow(force: true)).synced, 1);
  });

  test('an update is never uploaded before its failed create', () async {
    final sos = await env.sos.trigger();
    await env.sosRepo.advance(sos.id, SosStatus.sentToGateway);
    gateway.offline = true;

    final result = await service.syncNow();
    expect(result.failed, 1);
    // Only the create was attempted; the update waits behind it.
    expect(gateway.pushed, ['sosEvent:${sos.id}:create']);

    // While the create is backing off the update is withheld too.
    expect(await queue.due(), isEmpty);
    expect((await queue.due(ignoreBackoff: true)).map((i) => i.operation), [
      SyncOperation.create,
      SyncOperation.update,
    ]);

    gateway.offline = false;
    await service.syncNow(force: true);
    expect(gateway.pushed.skip(1), [
      'sosEvent:${sos.id}:create',
      'sosEvent:${sos.id}:update',
    ]);
    expect((await env.sync.watchSummary().first).outstanding, 0);
  });

  test('items of different entities are independent', () async {
    final a = await env.sos.trigger();
    final b = await env.sos.trigger();
    gateway.offline = true;
    await service.syncNow();
    expect(gateway.pushed, hasLength(2)); // both attempted
    expect({a.id, b.id}, hasLength(2));
  });

  test(
    'a lost response is retried without creating a duplicate remote event',
    () async {
      final sos = await env.sos.trigger();
      await env.messaging.send(peerNodeId: 'PEER', body: 'hello');
      gateway.loseNextResponses =
          2; // both uploads reach the cloud, replies lost

      final first = await service.syncNow();
      expect((first.synced, first.failed), (0, 2));
      expect(gateway.cloud.received, hasLength(2));

      final second = await service.syncNow(force: true);
      expect((second.synced, second.failed), (2, 0));
      // Retried items overwrote their remote record instead of adding another.
      expect(
        gateway.cloud.received.keys,
        unorderedEquals([
          'sosEvent:${sos.id}:create',
          'message:${(await env.messages.search('hello')).single.id}:create',
        ]),
      );
      expect(await queue.due(ignoreBackoff: true), isEmpty);
    },
  );

  test('concurrent sync runs upload each item once', () async {
    await env.sos.trigger();
    await env.sos.trigger();
    final results = await Future.wait([service.syncNow(), service.syncNow()]);
    expect(results.map((r) => r.synced).reduce((a, b) => a + b), 2);
    expect(gateway.pushed, hasLength(2));
  });

  test(
    'an entity re-queued during upload is not marked synced with stale data',
    () async {
      final sos = await env.sos.trigger();
      await env.sosRepo.advance(sos.id, SosStatus.acknowledged);
      final update = (await queue.due()).firstWhere(
        (i) => i.operation == SyncOperation.update,
      );
      // The create has to be synced first for the update to be due.
      final create = (await queue.due()).first;
      await queue.markInProgress(create.id);
      await queue.markSynced(create.id, expectedPayload: create.payload);

      await queue.markInProgress(update.id);
      // The SOS changes again while the old snapshot is in flight.
      await env.sosRepo.advance(sos.id, SosStatus.propagated, nodesReached: 2);

      final applied = await queue.markSynced(
        update.id,
        expectedPayload: update.payload,
      );
      expect(applied, isFalse);
      final stored = (await queue.watchItems().first).firstWhere(
        (i) => i.id == update.id,
      );
      expect(stored.status, SyncStatus.pending);
      expect(stored.payload, contains('propagated'));
    },
  );

  test('markFailed only affects an upload that is still in progress', () async {
    await env.sos.trigger();
    final item = (await queue.due()).single;
    await queue.markFailed(item.id, 'stray'); // never started
    final unchanged = (await queue.watchItems().first).single;
    expect(unchanged.status, SyncStatus.pending);
    expect(unchanged.retryCount, 0);
  });

  test('an interrupted upload is recovered and then uploaded', () async {
    await env.sos.trigger();
    final item = (await queue.due()).single;
    await queue.markInProgress(item.id); // app killed mid-upload
    expect(await queue.due(ignoreBackoff: true), isEmpty);

    // A new process starts: nothing is stuck.
    final restarted = SyncService(queue: queue, cloud: gateway);
    await restarted.recoverInterrupted();
    expect((await restarted.syncNow()).synced, 1);
    expect((await queue.watchItems().first).single.status, SyncStatus.synced);
  });

  test('message delivery state is untouched by sync failures', () async {
    final sent = await env.messaging.send(peerNodeId: 'PEER', body: 'x');
    gateway.offline = true;
    await service.syncNow();
    final stored = (await env.messages.getMessage(sent.id))!;
    expect(stored.status, sent.status);
    expect(stored.failureReason, isNull);
  });
}
