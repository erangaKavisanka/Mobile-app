import '../constants/app_constants.dart';
import '../utils/id_generator.dart';
import 'protocol.dart';

/// Builds outbound protocol messages for the local node and parses typed
/// payloads from inbound ones. Keeps wire details out of services and UI.
class ProtocolFactory {
  ProtocolFactory({
    required this.localNodeId,
    IdGenerator idGenerator = const IdGenerator(),
    DateTime Function()? clock,
  }) : _ids = idGenerator,
       _clock = clock ?? DateTime.now,
       // Seconds since epoch keeps sequence numbers increasing across restarts
       // without having to persist a counter.
       _sequence = (clock ?? DateTime.now)().millisecondsSinceEpoch ~/ 1000;

  final String localNodeId;
  final IdGenerator _ids;
  final DateTime Function() _clock;
  int _sequence;

  ProtocolMessage _build(
    ProtocolMessageType type,
    String destinationId,
    Map<String, dynamic> payload, {
    String? messageId,
  }) {
    return ProtocolMessage(
      messageId: messageId ?? _ids.next(),
      type: type,
      sourceId: localNodeId,
      destinationId: destinationId,
      sequenceNumber: ++_sequence,
      hopLimit: AppConstants.defaultHopLimit,
      createdAt: _clock().toUtc(),
      payload: payload,
    );
  }

  ProtocolMessage text({
    required String messageId,
    required String destinationId,
    required String body,
    double? latitude,
    double? longitude,
    double? accuracy,
  }) {
    return _build(ProtocolMessageType.text, destinationId, {
      'text': body,
      if (latitude != null && longitude != null)
        'location': {'lat': latitude, 'lon': longitude, 'accuracy': ?accuracy},
    }, messageId: messageId);
  }

  ProtocolMessage sos({
    required String sosId,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? note,
  }) {
    return _build(ProtocolMessageType.sos, AppConstants.broadcastId, {
      'sos_id': sosId,
      if (latitude != null && longitude != null)
        'location': {'lat': latitude, 'lon': longitude, 'accuracy': ?accuracy},
      if (note != null && note.isNotEmpty) 'note': note,
    }, messageId: sosId);
  }

  ProtocolMessage ack({
    required String destinationId,
    required String ackFor,
    required AckStage stage,
    int? nodesReached,
  }) {
    return _build(ProtocolMessageType.ack, destinationId, {
      'ack_for': ackFor,
      'stage': stage.name,
      'nodes_reached': ?nodesReached,
    });
  }

  ProtocolMessage status({
    required String destinationId,
    required String name,
    required String role,
    int? batteryPercent,
    int? rssi,
    bool online = true,
  }) {
    return _build(ProtocolMessageType.status, destinationId, {
      'name': name,
      'role': role,
      'online': online,
      'battery': ?batteryPercent,
      'rssi': ?rssi,
    });
  }

  ProtocolMessage hello({
    required String destinationId,
    required String name,
    required String role,
    String? firmware,
  }) {
    return _build(ProtocolMessageType.hello, destinationId, {
      'name': name,
      'role': role,
      'firmware': ?firmware,
    });
  }

  ProtocolMessage error({
    required String destinationId,
    required String ref,
    required String code,
    String? detail,
  }) {
    return _build(ProtocolMessageType.error, destinationId, {
      'ref': ref,
      'code': code,
      'detail': ?detail,
    });
  }
}

/// Which hop of the path an ACK confirms.
enum AckStage {
  /// The gateway accepted and queued the packet for RF transmission.
  gateway,

  /// The destination node confirmed receipt of a text message.
  delivered,

  /// An SOS packet was re-broadcast by other nodes.
  propagated,
}

/// Typed read access to inbound payloads. Throws [FormatException] on bad
/// payloads so malformed packets can be dropped safely.
extension ProtocolPayloadReader on ProtocolMessage {
  String requireString(String key) {
    final value = payload[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Payload field "$key" must be a non-empty string.');
    }
    return value;
  }

  String? optionalString(String key) {
    final value = payload[key];
    return value is String ? value : null;
  }

  int? optionalInt(String key) {
    final value = payload[key];
    return value is num ? value.toInt() : null;
  }

  AckStage get ackStage {
    final name = requireString('stage');
    return AckStage.values.firstWhere(
      (s) => s.name == name,
      orElse: () => throw FormatException('Unknown ACK stage: $name'),
    );
  }

  /// Optional location. Absent -> null; present but invalid -> [FormatException].
  ({double lat, double lon, double? accuracy})? get location {
    final raw = payload['location'];
    if (raw == null) return null;
    if (raw is! Map) {
      throw const FormatException('"location" must be an object.');
    }
    final lat = raw['lat'];
    final lon = raw['lon'];
    if (lat is! num ||
        lon is! num ||
        lat < -90 ||
        lat > 90 ||
        lon < -180 ||
        lon > 180) {
      throw const FormatException('"location" has invalid coordinates.');
    }
    final acc = raw['accuracy'];
    if (acc != null && (acc is! num || acc < 0)) {
      throw const FormatException('"location.accuracy" must be non-negative.');
    }
    return (
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      accuracy: acc is num ? acc.toDouble() : null,
    );
  }

  /// Optional integer in [min]..[max]. Absent -> null; wrong type or out of
  /// range -> [FormatException], so a bad reading never becomes a stored one.
  int? boundedInt(String key, {required int min, required int max}) {
    final value = payload[key];
    if (value == null) return null;
    if (value is! int || value < min || value > max) {
      throw FormatException(
        'Payload field "$key" must be an integer $min..$max.',
      );
    }
    return value;
  }
}
