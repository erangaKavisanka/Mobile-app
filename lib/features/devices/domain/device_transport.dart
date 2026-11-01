import '../../../core/protocol/protocol.dart';

enum TransportConnectionState { disconnected, connecting, connected, error }

/// Link to the EcoLink gateway (ESP32-C3 over USB-OTG in production).
///
/// Everything above this interface speaks [ProtocolMessage]; framing and
/// serial I/O belong to the implementation. A future USB serial transport
/// replaces [SimulatedDeviceTransport] without touching messaging or SOS code.
abstract class DeviceTransport {
  /// True for implementations that fabricate traffic instead of talking to
  /// hardware. The UI uses this to label data as simulated.
  bool get isSimulated;

  TransportConnectionState get currentState;
  Stream<TransportConnectionState> get connectionState;

  /// Packets received from the gateway: ACK, ERROR, TEXT, SOS, STATUS, HELLO.
  Stream<ProtocolMessage> get incomingEvents;

  /// Throws [TransportException] if not connected.
  Future<void> connect();
  Future<void> disconnect();

  /// Throws [TransportException] if not connected or the write fails.
  Future<void> sendMessage(ProtocolMessage message);
  Future<void> sendSOS(ProtocolMessage message);

  /// Requests a STATUS packet from the gateway.
  Future<void> getStatus();

  Future<void> dispose();
}

/// Extra controls that only exist for simulated transports.
abstract class SimulationControls {
  Future<void> simulateIncomingMessage();
  Future<void> simulateIncomingSos();
}
