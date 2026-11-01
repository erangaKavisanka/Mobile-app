import 'package:ecolink/data/services/sync_service.dart';
import 'package:ecolink/features/location/domain/location_fix.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:ecolink/features/synchronization/domain/sync_item.dart';
import 'package:ecolink/features/synchronization/domain/sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  group('SOS lifecycle', () {
    test(
      'triggers offline with unique id, location, and queued sync',
      () async {
        await env.coordinator.start();
        final fix = LocationFix(
          latitude: 6.9271,
          longitude: 79.8612,
          accuracy: 8,
          recordedAt: DateTime.now(),
        );
        final a = await env.sos.trigger(location: fix, note: ' lost ');
        final b = await env.sos.trigger();
        expect(a.id, isNot(b.id));
        expect(a.status, SosStatus.triggered); // no gateway: not "sent"
        expect(a.latitude, 6.9271);
        expect(a.note, 'lost');
        expect(a.isActive, isTrue);
        expect(await env.sync.due(), hasLength(2));
      },
    );

    test(
      'progresses sentToGateway -> acknowledged -> propagated via ACKs',
      () async {
        await env.coordinator.start();
        await env.transport.connect();
        await env.until(
          () async => (await env.nodes.findByNodeId('GW-SIM-01')) != null,
        );
        final e = await env.sos.trigger();
        expect(e.status, SosStatus.sentToGateway);
        expect(e.sentAt, isNotNull);

        await env.until(
          () async =>
              (await env.sosRepo.get(e.id))!.status == SosStatus.propagated,
        );
        final done = (await env.sosRepo.get(e.id))!;
        expect(done.acknowledgedAt, isNotNull);
        expect(done.propagatedAt, isNotNull);
        expect(done.nodesReached, 2);
        expect(done.isSimulated, isTrue);
      },
    );

    test('an SOS raised offline is sent when the gateway connects', () async {
      await env.coordinator.start();
      final e = await env.sos.trigger();
      expect(e.status, SosStatus.triggered);
      await env.transport.connect();
      await env.until(
        () async =>
            (await env.sosRepo.get(e.id))!.status == SosStatus.propagated,
      );
    });

    test('resolve and cancel close the event permanently', () async {
      final a = await env.sos.trigger();
      final b = await env.sos.trigger();
      await env.sos.resolve(a.id);
      await env.sos.cancel(b.id);
      expect((await env.sosRepo.get(a.id))!.status, SosStatus.resolved);
      expect((await env.sosRepo.get(b.id))!.status, SosStatus.cancelled);
      expect(await env.sosRepo.active(), isEmpty);
      await env.sos.onGatewayAck(a.id);
      expect((await env.sosRepo.get(a.id))!.status, SosStatus.resolved);
    });

    test('remote SOS is recorded once, with the sender as source', () async {
      await env.coordinator.start();
      await env.transport.connect();
      await env.until(
        () async => (await env.nodes.findByNodeId('GW-SIM-01')) != null,
      );
      await env.transport.simulateIncomingSos();
      await env.until(() async => (await env.sosRepo.active()).isNotEmpty);
      final e = (await env.sosRepo.active()).single;
      expect(e.sourceNodeId, 'SIM-TRAV-C');
      expect(e.isSimulated, isTrue);
      expect(e.hasLocation, isFalse);
    });
  });

  group('Synchronization', () {
    SyncService serviceWith(bool Function() online) => SyncService(
      queue: env.sync,
      cloud: SimulatedCloudGateway(
        isInternetAvailable: online,
        latency: Duration.zero,
      ),
    );

    test(
      'fails and tracks retries while offline, succeeds when online',
      () async {
        await env.sos.trigger();
        var online = false;
        final svc = serviceWith(() => online);

        var r = await svc.syncNow();
        expect((r.synced, r.failed), (0, 1));
        // The retry is still inside its backoff window, so an automatic sync
        // skips it; only a forced (manual) sync retries immediately.
        expect((await svc.syncNow()).failed, 0);
        r = await svc.syncNow(force: true);
        expect(r.failed, 1);

        final failed = (await env.sync.watchItems().first).single;
        expect(failed.status, SyncStatus.failed);
        expect(failed.retryCount, 2);
        expect(failed.lastError, contains('No Internet'));
        var summary = await env.sync.watchSummary().first;
        expect(summary.failed, 1);
        expect(summary.lastError, isNotNull);
        expect(summary.lastSyncedAt, isNull);

        online = true;
        r = await svc.syncNow(force: true);
        expect((r.synced, r.failed), (1, 0));
        summary = await env.sync.watchSummary().first;
        expect(summary.outstanding, 0);
        expect(summary.synced, 1);
        expect(summary.lastSyncedAt, isNotNull);
        expect(await env.sync.due(), isEmpty);
      },
    );

    test('a status change after upload is queued again', () async {
      final e = await env.sos.trigger();
      final svc = serviceWith(() => true);
      await svc.syncNow();
      await env.sos.resolve(e.id);
      expect(await env.sync.due(), hasLength(1));
    });

    test('unexpected gateway errors are recorded, not thrown', () async {
      await env.sos.trigger();
      final svc = SyncService(queue: env.sync, cloud: _ThrowingCloud());
      final r = await svc.syncNow();
      expect(r.failed, 1);
      expect(
        (await env.sync.watchItems().first).single.lastError,
        contains('boom'),
      );
    });

    test('resetInterrupted returns stuck items to pending', () async {
      await env.sos.trigger();
      final item = (await env.sync.due()).single;
      await env.sync.markInProgress(item.id);
      expect(await env.sync.due(), isEmpty);
      await env.sync.resetInterrupted();
      expect(await env.sync.due(), hasLength(1));
    });

    test('message delivery state is independent of sync state', () async {
      final sent = await env.messaging.send(peerNodeId: 'B', body: 'x');
      await serviceWith(() => true).syncNow();
      expect((await env.sync.watchSummary().first).synced, 1);
      expect(
        (await env.messages.getMessage(sent.id))!.status.name,
        'queued',
      ); // uploaded to the "cloud" but never delivered over RF
    });
  });
}

class _ThrowingCloud implements CloudGateway {
  @override
  bool get isSimulated => true;
  @override
  Future<void> push(SyncItem item) async => throw StateError('boom');
}
