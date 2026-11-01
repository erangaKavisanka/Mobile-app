import 'dart:async';

import '../../core/constants/app_constants.dart';
import '../../core/protocol/protocol.dart';
import '../../core/protocol/protocol_factory.dart';
import '../../features/devices/domain/device_transport.dart';
import '../../features/devices/domain/node.dart';
import '../../features/devices/domain/node_repository.dart';
import 'messaging_service.dart';
import 'sos_service.dart';

/// Glue between the [DeviceTransport] and the app's services. It translates
/// inbound packets into repository updates, so neither the UI nor the
/// transport knows about the other.
///
/// Every packet is validated before it can change state:
/// - it must not claim to come from this phone;
/// - it must be addressed to this phone (ACK/ERROR strictly; others may also
///   be broadcast);
/// - payload fields must be present, correctly typed and in range;
/// - an ACK/ERROR must reference one of our own outgoing messages or SOS
///   events, and come from a node that is entitled to send it for that stage.
/// Anything else is dropped and logged as a warning.
class GatewayCoordinator {
  GatewayCoordinator({
    required DeviceTransport transport,
    required MessagingService messaging,
    required SosService sos,
    required NodeRepository nodes,
    DateTime Function()? clock,
  }) : _transport = transport,
       _messaging = messaging,
       _sos = sos,
       _nodes = nodes,
       _clock = clock ?? DateTime.now;

  final DeviceTransport _transport;
  final MessagingService _messaging;
  final SosService _sos;
  final NodeRepository _nodes;
  final DateTime Function() _clock;

  StreamSubscription<ProtocolMessage>? _packets;
  StreamSubscription<TransportConnectionState>? _states;
  Future<void> _chain = Future.value();

  String get _localId => _messaging.localNodeId;

  /// Starts listening. Packets are processed one at a time, in arrival order.
  Future<void> start() async {
    await _messaging.flushQueue(); // also repairs interrupted `local` rows
    _states = _transport.connectionState.listen(
      (s) => _enqueue(() => _onConnectionState(s)),
    );
    _packets = _transport.incomingEvents.listen(
      (p) => _enqueue(() => _onPacket(p)),
    );
  }

  void _enqueue(Future<void> Function() job) {
    _chain = _chain.then((_) => job()).catchError((Object e) {
      return _nodes.log('Internal error: $e', level: LogLevel.error);
    });
  }

  /// Completes when all packets received so far are processed. For tests.
  Future<void> get idle => _chain;

  Future<void> _onConnectionState(TransportConnectionState state) async {
    final tag = _transport.isSimulated ? ' (simulated)' : '';
    switch (state) {
      case TransportConnectionState.connected:
        await _nodes.log('Gateway connected$tag');
        await _messaging.flushQueue();
        await _sos.flushPending();
      case TransportConnectionState.disconnected:
        await _nodes.markAllOffline();
        await _nodes.log('Gateway disconnected$tag');
      case TransportConnectionState.connecting:
        await _nodes.log('Connecting to gateway$tag');
      case TransportConnectionState.error:
        await _nodes.markAllOffline();
        await _nodes.log('Gateway connection error$tag', level: LogLevel.error);
    }
  }

  Future<void> _reject(ProtocolMessage p, String why) => _nodes.log(
    'Ignored ${p.type.value} from ${p.sourceId}: $why',
    level: LogLevel.warning,
  );

  Future<void> _onPacket(ProtocolMessage p) async {
    try {
      if (p.sourceId == _localId) {
        await _reject(p, 'it claims to come from this phone');
        return;
      }
      // ACK and ERROR answer one of our requests, so they must be addressed
      // to us directly. Everything else may also be a broadcast.
      final direct =
          p.type == ProtocolMessageType.ack ||
          p.type == ProtocolMessageType.error;
      final forUs =
          p.destinationId == _localId ||
          (!direct && p.destinationId == AppConstants.broadcastId);
      if (!forUs) {
        await _reject(p, 'addressed to ${p.destinationId}');
        return;
      }

      switch (p.type) {
        case ProtocolMessageType.hello:
        case ProtocolMessageType.status:
          await _onStatus(p);
        case ProtocolMessageType.ack:
          await _onAck(p);
        case ProtocolMessageType.error:
          await _onError(p);
        case ProtocolMessageType.text:
          p.requireString('text');
          p.location; // validates the optional location
          final sender = await _touch(p.sourceId);
          if (await _messaging.receive(p)) {
            await _nodes.log('Message received', nodeRowId: sender.id);
          }
        case ProtocolMessageType.sos:
          if (p.requireString('sos_id') != p.messageId) {
            throw const FormatException('"sos_id" must equal message_id.');
          }
          p.location;
          final sender = await _touch(p.sourceId);
          if (await _sos.receiveRemote(p)) {
            await _nodes.log(
              'SOS received',
              nodeRowId: sender.id,
              level: LogLevel.warning,
            );
          }
      }
    } on FormatException catch (e) {
      await _nodes.log(
        'Dropped malformed ${p.type.value} packet from ${p.sourceId}: '
        '${e.message}',
        level: LogLevel.warning,
      );
    }
  }

  /// Marks a node as seen now (creating it if the packet came from a node we
  /// have not met, which only validated TEXT/SOS/STATUS/HELLO packets do).
  Future<Node> _touch(String nodeId) => _nodes.upsert(
    nodeId: nodeId,
    lastSeenAt: _clock(),
    status: NodeStatus.online,
  );

  /// Refreshes a node we already know; never creates records.
  Future<Node?> _touchKnown(Node? node) async =>
      node == null ? null : _touch(node.nodeId);

  Future<void> _onStatus(ProtocolMessage p) async {
    final roleName = p.optionalString('role');
    NodeRole? role;
    if (roleName != null) {
      role = NodeRole.values.where((r) => r.name == roleName).firstOrNull;
      if (role == null) throw FormatException('Unknown role "$roleName".');
    } else if (p.type == ProtocolMessageType.hello) {
      throw const FormatException('HELLO requires "role".');
    }
    final online = p.payload['online'];
    if (online != null && online is! bool) {
      throw const FormatException('"online" must be a boolean.');
    }
    final name = p.payload['name'];
    if (name != null && (name is! String || name.trim().isEmpty)) {
      throw const FormatException('"name" must be a non-empty string.');
    }
    final battery = p.boundedInt('battery', min: 0, max: 100);
    final rssi = p.boundedInt('rssi', min: -150, max: 0);

    // Gateway status is what authorises ACK/ERROR packets, so it cannot be
    // claimed or removed by an ordinary status report: only a HELLO may
    // introduce a gateway, and an established gateway keeps its role.
    final known = await _nodes.findByNodeId(p.sourceId);
    final wasGateway = known?.role == NodeRole.gateway;
    if (role == NodeRole.gateway &&
        !wasGateway &&
        p.type != ProtocolMessageType.hello) {
      return _reject(p, 'only HELLO can declare a gateway');
    }
    if (role != null && role != NodeRole.gateway && wasGateway) {
      return _reject(p, 'the role of an established gateway cannot change');
    }

    final node = await _nodes.upsert(
      nodeId: p.sourceId,
      name: name as String?,
      role: role,
      status: online == false ? NodeStatus.offline : NodeStatus.online,
      batteryPercent: battery,
      rssi: rssi,
      lastSeenAt: _clock(),
      isSimulated: _transport.isSimulated,
    );
    if (p.type == ProtocolMessageType.hello) {
      await _nodes.log('HELLO received', nodeRowId: node.id);
    }
  }

  Future<void> _onAck(ProtocolMessage p) async {
    final ref = p.requireString('ack_for');
    final stage = p.ackStage;
    final sender = await _nodes.findByNodeId(p.sourceId);
    final message = await _messaging.findOutgoing(ref);
    final sos = await _sos.findOwn(ref);
    if (message == null && sos == null) {
      return _reject(p, 'it acknowledges unknown reference $ref');
    }
    final fromGateway = sender?.role == NodeRole.gateway;

    final bool changed;
    switch (stage) {
      case AckStage.gateway:
        // Only the gateway can say it accepted a packet for transmission.
        if (!fromGateway) {
          return _reject(p, 'gateway-stage ACK from a non-gateway node');
        }
        changed = message != null
            ? await _messaging.markGatewayAccepted(ref)
            : await _sos.onGatewayAck(ref);
      case AckStage.delivered:
        // Delivery is confirmed by the destination itself, for messages only.
        if (message == null) {
          return _reject(p, '"delivered" ACK does not reference a message');
        }
        if (p.sourceId != message.recipientNodeId) {
          return _reject(
            p,
            'delivery must be confirmed by ${message.recipientNodeId}',
          );
        }
        changed = await _messaging.markDelivered(ref);
      case AckStage.propagated:
        if (sos == null) {
          return _reject(p, '"propagated" ACK does not reference an SOS');
        }
        if (!fromGateway) {
          return _reject(p, 'propagated ACK from a non-gateway node');
        }
        final reached = p.boundedInt('nodes_reached', min: 0, max: 10000);
        changed = await _sos.onPropagated(ref, reached ?? 0);
    }

    // Duplicate or stale ACKs change nothing and leave no trace.
    if (!changed) return;
    final seen = await _touchKnown(sender);
    await _nodes.log(
      'ACK (${stage.name}) for ${ref.substring(0, ref.length < 8 ? ref.length : 8)}',
      nodeRowId: seen?.id,
    );
  }

  Future<void> _onError(ProtocolMessage p) async {
    final ref = p.requireString('ref');
    final code = p.optionalString('code') ?? 'error';
    final detail = p.optionalString('detail') ?? code;
    final sender = await _nodes.findByNodeId(p.sourceId);
    if (sender?.role != NodeRole.gateway) {
      return _reject(p, 'ERROR from a non-gateway node');
    }

    final message = await _messaging.findOutgoing(ref);
    final sos = await _sos.findOwn(ref);
    final bool changed;
    final String subject;
    if (message != null) {
      changed = await _messaging.markFailed(ref, detail);
      subject = 'message';
    } else if (sos != null) {
      // An SOS never becomes a failed *message*; it has its own lifecycle.
      changed = await _sos.onTransmitFailed(ref);
      subject = 'SOS';
    } else {
      return _reject(p, 'ERROR references unknown id $ref');
    }
    if (!changed) return;
    await _nodes.log(
      'Gateway ERROR $code for $subject: $detail',
      nodeRowId: (await _touchKnown(sender))?.id,
      level: LogLevel.error,
    );
  }

  Future<void> dispose() async {
    await _packets?.cancel();
    await _states?.cancel();
  }
}
