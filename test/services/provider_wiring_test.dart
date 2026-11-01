import 'package:ecolink/app/providers.dart';
import 'package:ecolink/data/services/gateway_coordinator.dart';
import 'package:ecolink/data/services/messaging_service.dart';
import 'package:ecolink/data/services/sos_service.dart';
import 'package:ecolink/data/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_env.dart';

void main() {
  test('providers construct every service with matching parameters', () async {
    final db = memoryDatabase();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localNodeIdProvider.overrideWithValue('ECO-WIRED1'),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final messaging = container.read(messagingServiceProvider);
    final sos = container.read(sosServiceProvider);
    expect(messaging, isA<MessagingService>());
    expect(sos, isA<SosService>());
    expect(
      container.read(gatewayCoordinatorProvider),
      isA<GatewayCoordinator>(),
    );
    expect(container.read(syncServiceProvider), isA<SyncService>());
    expect(messaging.localNodeId, 'ECO-WIRED1');
    expect(sos.localNodeId, 'ECO-WIRED1');
    expect(container.read(deviceTransportProvider).isSimulated, isTrue);
  });

  test('the provider-built stack sends a message end to end', () async {
    final db = memoryDatabase();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localNodeIdProvider.overrideWithValue('ECO-WIRED1'),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final message = await container
        .read(messagingServiceProvider)
        .send(peerNodeId: 'PEER-1', body: 'wired');
    expect(message.senderNodeId, 'ECO-WIRED1');
    expect(message.status.name, 'queued'); // simulated gateway not connected
  });

  test('test environment builds all services', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    expect(env.messaging.localNodeId, env.localNodeId);
    expect(env.sos.localNodeId, env.localNodeId);
  });
}
