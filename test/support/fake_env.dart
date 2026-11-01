import 'package:ecolink/core/protocol/protocol.dart';
import 'package:ecolink/core/protocol/protocol_factory.dart';
import 'package:ecolink/data/database/app_database.dart';
import 'package:ecolink/data/repositories/message_repository_impl.dart';
import 'package:ecolink/data/repositories/node_repository_impl.dart';
import 'package:ecolink/data/repositories/sos_repository_impl.dart';
import 'package:ecolink/data/repositories/sync_repository_impl.dart';
import 'package:ecolink/data/services/gateway_coordinator.dart';
import 'package:ecolink/data/services/messaging_service.dart';
import 'package:ecolink/data/services/sos_service.dart';
import 'package:ecolink/features/devices/domain/node.dart';

import 'fake_transport.dart';
import 'test_env.dart';

/// Real repositories, services and coordinator around a [FakeDeviceTransport],
/// so tests can feed arbitrary (including hostile) packets.
class FakeEnv {
  FakeEnv({AppDatabase? database, bool connected = true})
    : db = database ?? memoryDatabase(),
      transport = FakeDeviceTransport(connected: connected) {
    messages = MessageRepositoryImpl(db);
    nodes = NodeRepositoryImpl(db);
    sosRepo = SosRepositoryImpl(db);
    sync = SyncRepositoryImpl(db);
    final protocol = ProtocolFactory(localNodeId: localNodeId);
    messaging = MessagingService(
      messages: messages,
      nodes: nodes,
      transport: transport,
      protocol: protocol,
    );
    sos = SosService(events: sosRepo, transport: transport, protocol: protocol);
    coordinator = GatewayCoordinator(
      transport: transport,
      messaging: messaging,
      sos: sos,
      nodes: nodes,
    );
  }

  static const localNodeId = 'ECO-TEST01';
  static const gatewayId = 'GW-1';
  static const peerId = 'PEER-1';

  final AppDatabase db;
  final FakeDeviceTransport transport;
  late final MessageRepositoryImpl messages;
  late final NodeRepositoryImpl nodes;
  late final SosRepositoryImpl sosRepo;
  late final SyncRepositoryImpl sync;
  late final MessagingService messaging;
  late final SosService sos;
  late final GatewayCoordinator coordinator;

  final gateway = ProtocolFactory(localNodeId: gatewayId);
  final peer = ProtocolFactory(localNodeId: peerId);
  final stranger = ProtocolFactory(localNodeId: 'STRANGER');

  /// Packets from a node that does not exist in the registry.
  ProtocolFactory get rogue => stranger;

  Future<void> settle() async {
    for (var i = 0; i < 3; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await coordinator.idle;
    }
  }

  Future<void> deliver(ProtocolMessage packet) async {
    transport.inject(packet);
    await settle();
  }

  /// Starts the coordinator and registers the gateway (HELLO) and peer.
  Future<void> startWithGateway() async {
    await coordinator.start();
    await deliver(
      gateway.hello(
        destinationId: localNodeId,
        name: 'Gateway',
        role: 'gateway',
      ),
    );
    await deliver(
      peer.status(
        destinationId: localNodeId,
        name: 'Peer',
        role: 'traveller',
        batteryPercent: 80,
        rssi: -80,
      ),
    );
  }

  ProtocolMessage ack(
    ProtocolFactory from,
    String ref,
    AckStage stage, {
    String? to,
    int? nodesReached,
  }) => from.ack(
    destinationId: to ?? localNodeId,
    ackFor: ref,
    stage: stage,
    nodesReached: nodesReached,
  );

  /// A packet with an arbitrary (possibly invalid) payload.
  ProtocolMessage raw(
    ProtocolMessageType type,
    Map<String, dynamic> payload, {
    String source = gatewayId,
    String? destination,
    String? messageId,
  }) => ProtocolMessage(
    messageId: messageId ?? 'raw-${payload.hashCode}',
    type: type,
    sourceId: source,
    destinationId: destination ?? localNodeId,
    sequenceNumber: 1,
    hopLimit: 4,
    createdAt: DateTime.now().toUtc(),
    payload: payload,
  );

  Future<List<DeviceLog>> logs() => nodes.watchLogs().first;

  Future<int> warningCount() async =>
      (await logs()).where((l) => l.level == LogLevel.warning).length;

  Future<int> nodeCount() async => (await nodes.watchNodes().first).length;

  Future<void> dispose() async {
    await coordinator.dispose();
    await transport.dispose();
    await db.close();
  }
}
