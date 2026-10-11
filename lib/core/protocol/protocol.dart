import 'dart:convert';

import '../constants/app_constants.dart';

enum ProtocolMessageType { hello, status, text, sos, ack, error }

extension ProtocolMessageTypeX on ProtocolMessageType {
  String get value => switch (this) {
    ProtocolMessageType.hello => 'HELLO',
    ProtocolMessageType.status => 'STATUS',
    ProtocolMessageType.text => 'TEXT',
    ProtocolMessageType.sos => 'SOS',
    ProtocolMessageType.ack => 'ACK',
    ProtocolMessageType.error => 'ERROR',
  };

  static ProtocolMessageType fromValue(String value) {
    final normalized = value.trim().toUpperCase();
    switch (normalized) {
      case 'HELLO':
        return ProtocolMessageType.hello;
      case 'STATUS':
        return ProtocolMessageType.status;
      case 'TEXT':
        return ProtocolMessageType.text;
      case 'SOS':
        return ProtocolMessageType.sos;
      case 'ACK':
        return ProtocolMessageType.ack;
      case 'ERROR':
        return ProtocolMessageType.error;
      default:
        throw FormatException('Unsupported protocol type: $value');
    }
  }
}

class ProtocolMessage {
  ProtocolMessage({
    required this.messageId,
    required this.type,
    required this.sourceId,
    required this.destinationId,
    required this.sequenceNumber,
    required this.hopLimit,
    required this.createdAt,
    required this.payload,
    this.protocolVersion = AppConstants.protocolVersion,
  });

  final int protocolVersion;
  final String messageId;
  final ProtocolMessageType type;
  final String sourceId;
  final String destinationId;
  final int sequenceNumber;
  final int hopLimit;
  final DateTime createdAt;
  final Map<String, dynamic> payload;

  factory ProtocolMessage.fromJson(Map<String, dynamic> json) {
    _validateJson(json);
    return ProtocolMessage(
      messageId: json['message_id'] as String,
      type: ProtocolMessageTypeX.fromValue(json['type'] as String),
      sourceId: json['source_id'] as String,
      destinationId: json['destination_id'] as String,
      sequenceNumber: json['sequence_number'] as int,
      hopLimit: json['hop_limit'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      protocolVersion:
          json['protocol_version'] as int? ?? AppConstants.protocolVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol_version': protocolVersion,
      'type': type.value,
      'message_id': messageId,
      'source_id': sourceId,
      'destination_id': destinationId,
      'sequence_number': sequenceNumber,
      'hop_limit': hopLimit,
      'created_at': createdAt.toUtc().toIso8601String(),
      'payload': payload,
    };
  }

  String toEncodedJson() => jsonEncode(toJson());

  static ProtocolMessage fromEncodedJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Protocol payload must decode to an object.');
    }
    return ProtocolMessage.fromJson(decoded);
  }

  static void _validateJson(Map<String, dynamic> json) {
    final requiredKeys = [
      'protocol_version',
      'type',
      'message_id',
      'source_id',
      'destination_id',
      'sequence_number',
      'hop_limit',
      'created_at',
      'payload',
    ];

    for (final key in requiredKeys) {
      if (!json.containsKey(key)) {
        throw FormatException('Missing protocol field: $key');
      }
    }

    final version = json['protocol_version'];
    if (version is! int || version != AppConstants.protocolVersion) {
      throw const FormatException('Unsupported protocol version.');
    }

    if ((json['type'] as String).trim().isEmpty) {
      throw const FormatException('Protocol type cannot be empty.');
    }

    if ((json['message_id'] as String).trim().isEmpty) {
      throw const FormatException('Message ID cannot be empty.');
    }

    if ((json['payload'] as Map).isEmpty) {
      throw const FormatException('Payload cannot be empty.');
    }
  }
}

class ProtocolEnvelope {
  ProtocolEnvelope({required this.message, required this.lengthBytes});

  final ProtocolMessage message;
  final int lengthBytes;

  factory ProtocolEnvelope.fromBytes(List<int> bytes) {
    final raw = utf8.decode(bytes);
    final msg = ProtocolMessage.fromEncodedJson(raw);
    return ProtocolEnvelope(message: msg, lengthBytes: bytes.length);
  }

  List<int> toBytes() => utf8.encode(toJson());

  String toJson() => message.toEncodedJson();
}
