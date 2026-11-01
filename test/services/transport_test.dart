import 'package:ecolink/core/errors/app_exception.dart';
import 'package:ecolink/core/protocol/protocol.dart';
import 'package:ecolink/core/protocol/protocol_factory.dart';
import 'package:ecolink/data/services/simulated_device_transport.dart';
import 'package:ecolink/features/devices/domain/device_transport.dart';
import 'package:flutter_test/flutter_test.dart';

SimulatedDeviceTransport make({double failureRate = 0}) =>
    SimulatedDeviceTransport(
      localNodeId: 'ME',
      connectDelay: Duration.zero,
      ackDelay: const Duration(milliseconds: 5),
      propagationDelay: const Duration(milliseconds: 10),
      failureRate: failureRate,
    );

Future<List<ProtocolMessage>> collect(
  SimulatedDeviceTransport t,
  Duration d,
) async {
  final out = <ProtocolMessage>[];
  final sub = t.incomingEvents.listen(out.add);
  await Future<void>.delayed(d);
  await sub.cancel();
  return out;
}

void main() {
  final factory = ProtocolFactory(localNodeId: 'ME');
  const wait = Duration(milliseconds: 120);

  test('connect emits state changes then HELLO and STATUS packets', () async {
    final t = make();
    addTearDown(t.dispose);
    final states = <TransportConnectionState>[];
    t.connectionState.listen(states.add);
    final packetsFuture = collect(t, wait);
    await t.connect();
    final packets = await packetsFuture;

    expect(states, [
      TransportConnectionState.connecting,
      TransportConnectionState.connected,
    ]);
    expect(packets.first.type, ProtocolMessageType.hello);
    final statusSources = packets
        .where((p) => p.type == ProtocolMessageType.status)
        .map((p) => p.sourceId)
        .toSet();
    expect(statusSources, {'GW-SIM-01', 'SIM-RELAY-B', 'SIM-TRAV-C'});
    expect(t.isSimulated, isTrue);
  });

  test('sending while disconnected throws TransportException', () async {
    final t = make();
    addTearDown(t.dispose);
    final msg = factory.text(
      messageId: 'm',
      destinationId: 'SIM-RELAY-B',
      body: 'x',
    );
    expect(() => t.sendMessage(msg), throwsA(isA<TransportException>()));
    expect(
      () => t.sendSOS(factory.sos(sosId: 's')),
      throwsA(isA<TransportException>()),
    );
  });

  test('text is acked by gateway then by destination', () async {
    final t = make();
    addTearDown(t.dispose);
    await t.connect();
    final collected = collect(t, wait);
    await t.sendMessage(
      factory.text(messageId: 'm1', destinationId: 'SIM-RELAY-B', body: 'hi'),
    );
    final acks = (await collected)
        .where((p) => p.type == ProtocolMessageType.ack)
        .toList();
    expect(acks.map((a) => a.ackStage), [AckStage.gateway, AckStage.delivered]);
    expect(acks.last.sourceId, 'SIM-RELAY-B');
    expect(acks.every((a) => a.payload['ack_for'] == 'm1'), isTrue);
  });

  test(
    'unknown destination yields ERROR no_route and no delivery ACK',
    () async {
      final t = make();
      addTearDown(t.dispose);
      await t.connect();
      final collected = collect(t, wait);
      await t.sendMessage(
        factory.text(messageId: 'm1', destinationId: 'NOBODY', body: 'hi'),
      );
      final packets = await collected;
      expect(packets.any((p) => p.type == ProtocolMessageType.error), isTrue);
      expect(
        packets
            .where((p) => p.type == ProtocolMessageType.ack)
            .map((p) => p.ackStage),
        [AckStage.gateway],
      );
    },
  );

  test('failureRate 1 produces ERROR instead of ACK', () async {
    final t = make(failureRate: 1);
    addTearDown(t.dispose);
    await t.connect();
    final collected = collect(t, wait);
    await t.sendMessage(
      factory.text(messageId: 'm1', destinationId: 'SIM-RELAY-B', body: 'hi'),
    );
    final packets = await collected;
    expect(packets.single.type, ProtocolMessageType.error);
    expect(packets.single.payload['ref'], 'm1');
  });

  test('SOS is acked by gateway then propagated to simulated nodes', () async {
    final t = make();
    addTearDown(t.dispose);
    await t.connect();
    final collected = collect(t, wait);
    await t.sendSOS(factory.sos(sosId: 'sos-1'));
    final acks = (await collected)
        .where((p) => p.type == ProtocolMessageType.ack)
        .toList();
    expect(acks.map((a) => a.ackStage), [
      AckStage.gateway,
      AckStage.propagated,
    ]);
    expect(acks.last.optionalInt('nodes_reached'), 2);
  });

  test('disconnecting cancels pending acknowledgements', () async {
    final t = make();
    addTearDown(t.dispose);
    await t.connect();
    final collected = collect(t, wait);
    await t.sendMessage(
      factory.text(messageId: 'm1', destinationId: 'SIM-RELAY-B', body: 'hi'),
    );
    await t.disconnect();
    expect(await collected, isEmpty);
    expect(t.currentState, TransportConnectionState.disconnected);
  });

  test(
    'simulateIncoming* emit TEXT and SOS addressed to the local node',
    () async {
      final t = make();
      addTearDown(t.dispose);
      await t.connect();
      final collected = collect(t, const Duration(milliseconds: 30));
      await t.simulateIncomingMessage();
      await t.simulateIncomingSos();
      final packets = await collected;
      final text = packets.firstWhere(
        (p) => p.type == ProtocolMessageType.text,
      );
      expect(text.destinationId, 'ME');
      expect(text.requireString('text'), isNotEmpty);
      expect(packets.any((p) => p.type == ProtocolMessageType.sos), isTrue);
    },
  );

  test('every emitted packet survives serialization', () async {
    final t = make();
    addTearDown(t.dispose);
    final collected = collect(t, wait);
    await t.connect();
    await t.getStatus();
    for (final p in await collected) {
      expect(
        () => ProtocolMessage.fromEncodedJson(p.toEncodedJson()),
        returnsNormally,
      );
    }
  });
}
