import 'dart:async';

import 'package:ecolink/core/errors/app_exception.dart';
import 'package:ecolink/core/protocol/protocol.dart';
import 'package:ecolink/features/devices/domain/device_transport.dart';

/// A scriptable transport: tests inject inbound packets, flip the connection
/// state and make writes fail. Nothing is generated automatically.
class FakeDeviceTransport implements DeviceTransport {
  FakeDeviceTransport({bool connected = true})
    : _state = connected
          ? TransportConnectionState.connected
          : TransportConnectionState.disconnected;

  final _events = StreamController<ProtocolMessage>.broadcast();
  final _states = StreamController<TransportConnectionState>.broadcast();
  TransportConnectionState _state;

  final List<ProtocolMessage> sentMessages = [];
  final List<ProtocolMessage> sentSos = [];

  /// When set, the next sends throw it (until cleared).
  TransportException? sendError;

  @override
  bool get isSimulated => false;

  @override
  TransportConnectionState get currentState => _state;

  @override
  Stream<TransportConnectionState> get connectionState => _states.stream;

  @override
  Stream<ProtocolMessage> get incomingEvents => _events.stream;

  void setState(TransportConnectionState state) {
    _state = state;
    _states.add(state);
  }

  void inject(ProtocolMessage packet) => _events.add(packet);

  @override
  Future<void> connect() async => setState(TransportConnectionState.connected);

  @override
  Future<void> disconnect() async =>
      setState(TransportConnectionState.disconnected);

  @override
  Future<void> sendMessage(ProtocolMessage message) async {
    if (sendError != null) throw sendError!;
    sentMessages.add(message);
  }

  @override
  Future<void> sendSOS(ProtocolMessage message) async {
    if (sendError != null) throw sendError!;
    sentSos.add(message);
  }

  @override
  Future<void> getStatus() async {}

  @override
  Future<void> dispose() async {
    await _events.close();
    await _states.close();
  }
}
