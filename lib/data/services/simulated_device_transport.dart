import 'dart:async';
import 'dart:math';

import '../../core/errors/app_exception.dart';
import '../../core/protocol/protocol.dart';
import '../../core/protocol/protocol_factory.dart';
import '../../features/devices/domain/device_transport.dart';

/// A fake gateway used until ESP32-C3 hardware is attached.
///
/// It behaves like a gateway would at the protocol level (HELLO, STATUS, ACK,
/// ERROR, incoming TEXT/SOS) but nothing here touches USB, LoRa, or any
/// network. Everything it produces is simulated and labelled as such by the UI.
class SimulatedDeviceTransport implements DeviceTransport, SimulationControls {
  SimulatedDeviceTransport({
    required this.localNodeId,
    this.connectDelay = const Duration(milliseconds: 900),
    this.ackDelay = const Duration(milliseconds: 700),
    this.propagationDelay = const Duration(seconds: 2),
    this.statusInterval,
    this.failureRate = 0,
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random(),
       _clock = clock ?? DateTime.now,
       _gateway = ProtocolFactory(localNodeId: gatewayId, clock: clock) {
    for (final n in _nodes) {
      _factories[n.nodeId] = ProtocolFactory(
        localNodeId: n.nodeId,
        clock: clock,
      );
    }
  }

  static const gatewayId = 'GW-SIM-01';

  final String localNodeId;
  final Duration connectDelay;
  final Duration ackDelay;
  final Duration propagationDelay;

  /// Interval between unsolicited STATUS packets; null disables them.
  final Duration? statusInterval;

  /// Probability (0..1) that the gateway answers a send with an ERROR.
  final double failureRate;

  final Random _random;
  final DateTime Function() _clock;
  final ProtocolFactory _gateway;
  final Map<String, ProtocolFactory> _factories = {};

  final _SimNode _relay = _SimNode(
    'SIM-RELAY-B',
    'Simulated Relay B',
    'relay',
    battery: 81,
    rssi: -78,
  );
  final _SimNode _traveller = _SimNode(
    'SIM-TRAV-C',
    'Simulated Traveller C',
    'traveller',
    battery: 64,
    rssi: -91,
  );
  List<_SimNode> get _nodes => [_relay, _traveller];

  final _events = StreamController<ProtocolMessage>.broadcast();
  final _states = StreamController<TransportConnectionState>.broadcast();
  TransportConnectionState _state = TransportConnectionState.disconnected;
  Timer? _statusTimer;
  int _session = 0;

  static const _cannedMessages = [
    'Reached the viewpoint. Signal is weak up here.',
    'Trail is washed out past the bridge, take the east path.',
    'Weather turning, heading back to camp.',
    'Anyone near the river crossing?',
    'Battery getting low, will check in again at noon.',
  ];

  @override
  bool get isSimulated => true;

  @override
  TransportConnectionState get currentState => _state;

  @override
  Stream<TransportConnectionState> get connectionState => _states.stream;

  @override
  Stream<ProtocolMessage> get incomingEvents => _events.stream;

  void _setState(TransportConnectionState value) {
    _state = value;
    if (!_states.isClosed) _states.add(value);
  }

  bool get _connected => _state == TransportConnectionState.connected;

  void _emit(ProtocolMessage message) {
    if (!_events.isClosed) _events.add(message);
  }

  /// Runs [action] after [delay] only if the same connection is still up.
  void _later(Duration delay, void Function() action) {
    final session = _session;
    Future<void>.delayed(delay, () {
      if (_connected && session == _session) action();
    });
  }

  @override
  Future<void> connect() async {
    if (_state == TransportConnectionState.connected ||
        _state == TransportConnectionState.connecting) {
      return;
    }
    final session = ++_session;
    _setState(TransportConnectionState.connecting);
    await Future<void>.delayed(connectDelay);
    if (session != _session) return; // disconnected while connecting
    _setState(TransportConnectionState.connected);

    _emit(
      _gateway.hello(
        destinationId: localNodeId,
        name: 'Simulated Gateway',
        role: 'gateway',
        firmware: 'sim-0.1',
      ),
    );
    _emitStatuses();
    final interval = statusInterval;
    if (interval != null) {
      _statusTimer = Timer.periodic(interval, (_) {
        if (!_connected) return;
        for (final n in _nodes) {
          n.battery = max(5, n.battery - _random.nextInt(2));
          n.rssi = (n.rssi + _random.nextInt(5) - 2).clamp(-120, -50);
        }
        _emitStatuses();
      });
    }
  }

  @override
  Future<void> disconnect() async {
    _session++;
    _statusTimer?.cancel();
    _statusTimer = null;
    _setState(TransportConnectionState.disconnected);
  }

  void _emitStatuses() {
    _emit(
      _gateway.status(
        destinationId: localNodeId,
        name: 'Simulated Gateway',
        role: 'gateway',
      ),
    );
    for (final n in _nodes) {
      _emit(
        _factories[n.nodeId]!.status(
          destinationId: localNodeId,
          name: n.name,
          role: n.role,
          batteryPercent: n.battery,
          rssi: n.rssi,
        ),
      );
    }
  }

  void _requireConnected() {
    if (!_connected) {
      throw const TransportException('Gateway is not connected.');
    }
  }

  @override
  Future<void> sendMessage(ProtocolMessage message) async {
    _requireConnected();
    if (message.type != ProtocolMessageType.text) {
      throw const TransportException('sendMessage only accepts TEXT packets.');
    }
    _later(ackDelay, () {
      if (_random.nextDouble() < failureRate) {
        _emit(
          _gateway.error(
            destinationId: localNodeId,
            ref: message.messageId,
            code: 'tx_failed',
            detail: 'Simulated radio transmit failure',
          ),
        );
        return;
      }
      _emit(
        _gateway.ack(
          destinationId: localNodeId,
          ackFor: message.messageId,
          stage: AckStage.gateway,
        ),
      );
      final target = _factories[message.destinationId];
      if (target == null) {
        _later(ackDelay, () {
          _emit(
            _gateway.error(
              destinationId: localNodeId,
              ref: message.messageId,
              code: 'no_route',
              detail: 'No simulated route to ${message.destinationId}',
            ),
          );
        });
        return;
      }
      _later(ackDelay, () {
        _emit(
          target.ack(
            destinationId: localNodeId,
            ackFor: message.messageId,
            stage: AckStage.delivered,
          ),
        );
      });
    });
  }

  @override
  Future<void> sendSOS(ProtocolMessage message) async {
    _requireConnected();
    if (message.type != ProtocolMessageType.sos) {
      throw const TransportException('sendSOS only accepts SOS packets.');
    }
    _later(ackDelay, () {
      _emit(
        _gateway.ack(
          destinationId: localNodeId,
          ackFor: message.messageId,
          stage: AckStage.gateway,
        ),
      );
      _later(propagationDelay, () {
        _emit(
          _gateway.ack(
            destinationId: localNodeId,
            ackFor: message.messageId,
            stage: AckStage.propagated,
            nodesReached: _nodes.length,
          ),
        );
      });
    });
  }

  @override
  Future<void> getStatus() async {
    _requireConnected();
    _later(Duration.zero, _emitStatuses);
  }

  @override
  Future<void> simulateIncomingMessage() async {
    _requireConnected();
    final node = _nodes[_random.nextInt(_nodes.length)];
    _emit(
      _factories[node.nodeId]!.text(
        messageId:
            'sim-${_clock().microsecondsSinceEpoch}-${_random.nextInt(9999)}',
        destinationId: localNodeId,
        body: _cannedMessages[_random.nextInt(_cannedMessages.length)],
      ),
    );
  }

  @override
  Future<void> simulateIncomingSos() async {
    _requireConnected();
    final node = _traveller;
    final id = 'sim-sos-${_clock().microsecondsSinceEpoch}';
    _emit(
      _factories[node.nodeId]!.sos(
        sosId: id,
        note: 'Simulated emergency from ${node.name}',
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _session++;
    _statusTimer?.cancel();
    await _events.close();
    await _states.close();
  }
}

class _SimNode {
  _SimNode(
    this.nodeId,
    this.name,
    this.role, {
    required this.battery,
    required this.rssi,
  });

  final String nodeId;
  final String name;
  final String role;
  int battery;
  int rssi;
}
