import 'dart:convert';

import 'package:ecolink/core/protocol/protocol.dart';
import 'package:ecolink/core/protocol/protocol_factory.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> validJson() => {
  'protocol_version': 1,
  'type': 'TEXT',
  'message_id': 'abc',
  'source_id': 'A',
  'destination_id': 'B',
  'sequence_number': 1,
  'hop_limit': 4,
  'created_at': '2026-10-11T12:00:00.000Z',
  'payload': {'text': 'Hello'},
};

void main() {
  group('ProtocolMessage', () {
    test('round-trips through JSON', () {
      final original = ProtocolMessage.fromJson(validJson());
      final decoded = ProtocolMessage.fromEncodedJson(original.toEncodedJson());
      expect(decoded.messageId, 'abc');
      expect(decoded.type, ProtocolMessageType.text);
      expect(decoded.createdAt, DateTime.utc(2026, 10, 11, 12));
      expect(decoded.payload['text'], 'Hello');
    });

    test('round-trips through envelope bytes', () {
      final msg = ProtocolMessage.fromJson(validJson());
      final env = ProtocolEnvelope.fromBytes(
        ProtocolEnvelope(message: msg, lengthBytes: 0).toBytes(),
      );
      expect(env.message.sourceId, 'A');
      expect(env.lengthBytes, msg.encodedLength);
    });

    test('rejects missing fields', () {
      final json = validJson()..remove('message_id');
      expect(() => ProtocolMessage.fromJson(json), throwsFormatException);
    });

    test('rejects wrong protocol version', () {
      final json = validJson()..['protocol_version'] = 2;
      expect(() => ProtocolMessage.fromJson(json), throwsFormatException);
    });

    test('rejects unknown type', () {
      final json = validJson()..['type'] = 'WAT';
      expect(() => ProtocolMessage.fromJson(json), throwsFormatException);
    });

    test(
      'rejects wrongly typed fields with FormatException, not TypeError',
      () {
        expect(
          () =>
              ProtocolMessage.fromJson(validJson()..['sequence_number'] = 'x'),
          throwsFormatException,
        );
        expect(
          () => ProtocolMessage.fromJson(validJson()..['message_id'] = 5),
          throwsFormatException,
        );
        expect(
          () => ProtocolMessage.fromJson(validJson()..['payload'] = 'nope'),
          throwsFormatException,
        );
      },
    );

    test('rejects empty identities and negative counters', () {
      for (final key in ['source_id', 'destination_id']) {
        expect(
          () => ProtocolMessage.fromJson(validJson()..[key] = '  '),
          throwsFormatException,
        );
        expect(
          () => ProtocolMessage.fromJson(validJson()..[key] = 7),
          throwsFormatException,
        );
      }
      expect(
        () => ProtocolMessage.fromJson(validJson()..['sequence_number'] = -1),
        throwsFormatException,
      );
      expect(
        () => ProtocolMessage.fromJson(validJson()..['hop_limit'] = -1),
        throwsFormatException,
      );
    });

    test('payload readers reject out-of-range values', () {
      ProtocolMessage withPayload(Map<String, dynamic> payload) =>
          ProtocolMessage.fromJson(validJson()..['payload'] = payload);

      expect(
        withPayload({'battery': 100}).boundedInt('battery', min: 0, max: 100),
        100,
      );
      expect(
        withPayload({'x': 1}).boundedInt('battery', min: 0, max: 100),
        isNull,
      );
      for (final bad in [101, -1, '50', 5.5]) {
        expect(
          () =>
              withPayload({'battery': bad})
                  .boundedInt('battery', min: 0, max: 100),
          throwsFormatException,
        );
      }
      expect(withPayload({'text': 'a'}).location, isNull);
      expect(
        withPayload({
          'location': {'lat': 6.9, 'lon': 79.8},
        }).location!.lat,
        6.9,
      );
      for (final bad in [
        'here',
        {'lat': 91, 'lon': 0},
        {'lat': 0, 'lon': -181},
        {'lat': 'x', 'lon': 0},
        {'lat': 0, 'lon': 0, 'accuracy': -3},
      ]) {
        expect(
          () => withPayload({'location': bad}).location,
          throwsFormatException,
        );
      }
    });

    test('rejects empty payload and malformed JSON', () {
      expect(
        () => ProtocolMessage.fromJson(validJson()..['payload'] = {}),
        throwsFormatException,
      );
      expect(
        () => ProtocolMessage.fromEncodedJson('{oops'),
        throwsFormatException,
      );
      expect(
        () => ProtocolMessage.fromEncodedJson('[1,2]'),
        throwsFormatException,
      );
    });

    test('reports UTF-8 encoded size', () {
      final msg = ProtocolMessage.fromJson(
        validJson()..['payload'] = {'text': 'é'},
      );
      expect(msg.encodedLength, utf8.encode(msg.toEncodedJson()).length);
    });
  });

  group('ProtocolFactory', () {
    final factory = ProtocolFactory(
      localNodeId: 'ME',
      clock: () => DateTime.utc(2026),
    );

    test('builds text with location and increasing sequence numbers', () {
      final a = factory.text(
        messageId: 'm1',
        destinationId: 'B',
        body: 'hi',
        latitude: 6.9,
        longitude: 79.8,
        accuracy: 5,
      );
      final b = factory.text(messageId: 'm2', destinationId: 'B', body: 'yo');
      expect(b.sequenceNumber, greaterThan(a.sequenceNumber));
      final parsed = ProtocolMessage.fromEncodedJson(a.toEncodedJson());
      expect(parsed.location!.lat, 6.9);
      expect(parsed.location!.accuracy, 5);
      expect(
        ProtocolMessage.fromEncodedJson(b.toEncodedJson()).location,
        isNull,
      );
    });

    test('SOS uses the event id as message id', () {
      final sos = factory.sos(sosId: 'sos-1', note: 'help');
      expect(sos.messageId, 'sos-1');
      expect(sos.type, ProtocolMessageType.sos);
      expect(sos.requireString('sos_id'), 'sos-1');
    });

    test('ACK stage parses and rejects unknown stages', () {
      final ack = factory.ack(
        destinationId: 'B',
        ackFor: 'm1',
        stage: AckStage.delivered,
      );
      expect(ack.ackStage, AckStage.delivered);
      final bad = ProtocolMessage.fromJson(
        validJson()
          ..['type'] = 'ACK'
          ..['payload'] = {'ack_for': 'x', 'stage': 'teleported'},
      );
      expect(() => bad.ackStage, throwsFormatException);
    });

    test('status omits unknown readings', () {
      final s = factory.status(destinationId: 'B', name: 'n', role: 'relay');
      expect(s.payload.containsKey('battery'), isFalse);
      expect(s.optionalInt('rssi'), isNull);
    });
  });
}
