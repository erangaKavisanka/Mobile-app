import '../../core/errors/app_exception.dart';
import '../../core/protocol/protocol.dart';
import '../../core/protocol/protocol_factory.dart';
import '../../core/utils/id_generator.dart';
import '../../features/devices/domain/device_transport.dart';
import '../../features/location/domain/location_fix.dart';
import '../../features/sos/domain/sos_event.dart';
import '../../features/sos/domain/sos_repository.dart';

/// Owns the SOS lifecycle. State only moves forward; see [SosStatus].
class SosService {
  SosService({
    required SosRepository events,
    required DeviceTransport transport,
    required ProtocolFactory protocol,
    IdGenerator ids = const IdGenerator(),
    DateTime Function()? clock,
  }) : _events = events,
       _transport = transport,
       _protocol = protocol,
       _ids = ids,
       _clock = clock ?? DateTime.now;

  final SosRepository _events;
  final DeviceTransport _transport;
  final ProtocolFactory _protocol;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  String get localNodeId => _protocol.localNodeId;

  bool get _linkUp =>
      _transport.currentState == TransportConnectionState.connected;

  /// Creates and persists an SOS event, then transmits it when the gateway is
  /// connected. With no gateway the event stays `triggered` and is sent on
  /// the next connection.
  Future<SosEvent> trigger({LocationFix? location, String? note}) async {
    final now = _clock();
    final event = SosEvent(
      id: _ids.next(),
      sourceNodeId: localNodeId,
      status: SosStatus.triggered,
      createdAt: now,
      updatedAt: now,
      latitude: location?.latitude,
      longitude: location?.longitude,
      accuracy: location?.accuracy,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
    );
    await _events.create(event);
    if (_linkUp) await _transmit(event);
    return (await _events.get(event.id))!;
  }

  Future<void> _transmit(SosEvent event) async {
    try {
      await _transport.sendSOS(
        _protocol.sos(
          sosId: event.id,
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          note: event.note,
        ),
      );
      await _events.advance(event.id, SosStatus.sentToGateway);
    } on TransportException {
      // Stay `triggered`; the next flush retries.
    }
  }

  /// Sends SOS events that were never accepted by a gateway: those created
  /// while it was unreachable (`triggered`) and those it rejected (`failed`).
  Future<void> flushPending() async {
    for (final e in await _events.active()) {
      final unsent =
          e.status == SosStatus.triggered || e.status == SosStatus.failed;
      if (e.sourceNodeId == localNodeId && unsent) {
        if (!_linkUp) return;
        await _transmit(e);
      }
    }
  }

  /// Re-sends an own SOS whose transmission failed.
  Future<void> retry(String sosId) async {
    final event = await findOwn(sosId);
    if (event == null || event.status != SosStatus.failed || !_linkUp) return;
    await _transmit(event);
  }

  /// The SOS with [id] if it was raised by this phone.
  Future<SosEvent?> findOwn(String id) async {
    final event = await _events.get(id);
    return event != null && event.sourceNodeId == localNodeId ? event : null;
  }

  Future<bool> _advance(
    String id,
    SosStatus status, {
    int? nodesReached,
    bool simulated = false,
  }) async {
    final before = await _events.get(id);
    if (before == null) return false;
    await _events.advance(
      id,
      status,
      nodesReached: nodesReached,
      simulated: simulated,
    );
    final after = (await _events.get(id))!;
    return after.status != before.status ||
        after.nodesReached != before.nodesReached;
  }

  /// Gateway accepted the SOS. Returns false for stale or duplicate ACKs.
  Future<bool> onGatewayAck(String sosId) => _advance(
    sosId,
    SosStatus.acknowledged,
    simulated: _transport.isSimulated,
  );

  Future<bool> onPropagated(String sosId, int nodesReached) => _advance(
    sosId,
    SosStatus.propagated,
    nodesReached: nodesReached,
    simulated: _transport.isSimulated,
  );

  /// The gateway reported that it could not transmit the SOS.
  Future<bool> onTransmitFailed(String sosId) =>
      _advance(sosId, SosStatus.failed);

  /// The situation is over. Local and cloud-sync only: no RF cancel packet exists in
  /// protocol v1, so other nodes are not told.
  Future<void> resolve(String sosId) =>
      _events.advance(sosId, SosStatus.resolved);

  /// The SOS was raised by mistake. Same RF caveat as [resolve].
  Future<void> cancel(String sosId) =>
      _events.advance(sosId, SosStatus.cancelled);

  /// Records an SOS broadcast by another node. Duplicates are ignored.
  Future<bool> receiveRemote(ProtocolMessage packet) {
    final location = packet.location;
    final now = _clock();
    return _events.create(
      SosEvent(
        id: packet.requireString('sos_id'),
        sourceNodeId: packet.sourceId,
        status: SosStatus.propagated,
        createdAt: packet.createdAt,
        updatedAt: now,
        propagatedAt: now,
        latitude: location?.lat,
        longitude: location?.lon,
        accuracy: location?.accuracy,
        note: packet.optionalString('note'),
        isSimulated: _transport.isSimulated,
      ),
    );
  }
}
