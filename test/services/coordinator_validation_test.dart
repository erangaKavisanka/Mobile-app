import 'package:ecolink/core/errors/app_exception.dart';
import 'package:ecolink/core/protocol/protocol.dart';
import 'package:ecolink/core/protocol/protocol_factory.dart';
import 'package:ecolink/features/devices/domain/device_transport.dart';
import 'package:ecolink/features/devices/domain/node.dart';
import 'package:ecolink/features/messaging/domain/message.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_env.dart';

void main() {
  late FakeEnv env;
  setUp(() => env = FakeEnv());
  tearDown(() => env.dispose());

  Future<MessageStatus> statusOf(String id) async =>
      (await env.messages.getMessage(id))!.status;

  Future<SosStatus> sosStatusOf(String id) async =>
      (await env.sosRepo.get(id))!.status;

  group('service construction', () {
    test('services expose the local identity they were built with', () {
      expect(env.messaging.localNodeId, FakeEnv.localNodeId);
      expect(env.sos.localNodeId, FakeEnv.localNodeId);
    });
  });

  group('ACK source and reference validation', () {
    test('gateway-stage ACK is accepted only from a gateway', () async {
      env = FakeEnv(connected: false);
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      expect(sent.status, MessageStatus.queued);

      // The peer (a traveller) cannot claim the gateway accepted the packet.
      await env.deliver(env.ack(env.peer, sent.id, AckStage.gateway));
      expect(await statusOf(sent.id), MessageStatus.queued);

      await env.deliver(env.ack(env.gateway, sent.id, AckStage.gateway));
      expect(await statusOf(sent.id), MessageStatus.sentToGateway);
    });

    test(
      'delivery must be confirmed by the recipient, not the gateway',
      () async {
        await env.startWithGateway();
        final sent = await env.messaging.send(
          peerNodeId: FakeEnv.peerId,
          body: 'hi',
        );
        expect(sent.status, MessageStatus.sentToGateway);

        await env.deliver(env.ack(env.gateway, sent.id, AckStage.delivered));
        expect(await statusOf(sent.id), MessageStatus.sentToGateway);

        await env.deliver(env.ack(env.rogue, sent.id, AckStage.delivered));
        expect(await statusOf(sent.id), MessageStatus.sentToGateway);

        await env.deliver(env.ack(env.peer, sent.id, AckStage.delivered));
        expect(await statusOf(sent.id), MessageStatus.delivered);
      },
    );

    test(
      'duplicate and stale ACKs change nothing and leave no extra trace',
      () async {
        await env.startWithGateway();
        final sent = await env.messaging.send(
          peerNodeId: FakeEnv.peerId,
          body: 'hi',
        );
        await env.deliver(env.ack(env.peer, sent.id, AckStage.delivered));
        final logsAfterFirst = (await env.logs()).length;
        final updatedAt = (await env.messages.getMessage(sent.id))!.updatedAt;

        await env.deliver(env.ack(env.peer, sent.id, AckStage.delivered));
        // A late gateway ACK must not move a delivered message backwards.
        await env.deliver(env.ack(env.gateway, sent.id, AckStage.gateway));

        expect(await statusOf(sent.id), MessageStatus.delivered);
        expect((await env.messages.getMessage(sent.id))!.updatedAt, updatedAt);
        expect((await env.logs()).length, logsAfterFirst);
      },
    );

    test(
      'ACK for an unknown reference is ignored and creates no node',
      () async {
        await env.startWithGateway();
        final nodesBefore = await env.nodeCount();
        final warningsBefore = await env.warningCount();

        await env.deliver(env.ack(env.rogue, 'no-such-id', AckStage.delivered));
        await env.deliver(env.ack(env.gateway, 'no-such-id', AckStage.gateway));

        expect(await env.nodeCount(), nodesBefore);
        expect(await env.warningCount(), warningsBefore + 2);
      },
    );

    test('ACK for an incoming message is ignored', () async {
      await env.startWithGateway();
      await env.deliver(
        env.peer.text(
          messageId: 'incoming-1',
          destinationId: FakeEnv.localNodeId,
          body: 'hello',
        ),
      );
      final before = await env.messages.getMessage('incoming-1');
      await env.deliver(env.ack(env.peer, 'incoming-1', AckStage.delivered));
      expect(
        (await env.messages.getMessage('incoming-1'))!.updatedAt,
        before!.updatedAt,
      );
    });

    test('ACK addressed to another node or broadcast is ignored', () async {
      env = FakeEnv(connected: false);
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      await env.deliver(
        env.ack(env.gateway, sent.id, AckStage.gateway, to: 'SOMEONE-ELSE'),
      );
      await env.deliver(
        env.ack(env.gateway, sent.id, AckStage.gateway, to: 'BROADCAST'),
      );
      expect(await statusOf(sent.id), MessageStatus.queued);
    });

    test('packets claiming to come from this phone are ignored', () async {
      env = FakeEnv(connected: false);
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      final spoof = ProtocolFactory(localNodeId: FakeEnv.localNodeId);
      await env.deliver(
        spoof.ack(
          destinationId: FakeEnv.localNodeId,
          ackFor: sent.id,
          stage: AckStage.delivered,
        ),
      );
      expect(await statusOf(sent.id), MessageStatus.queued);
      expect(await env.nodes.findByNodeId(FakeEnv.localNodeId), isNull);
    });

    test('ACK stage must match the kind of record it references', () async {
      await env.startWithGateway();
      final msg = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      final sos = await env.sos.trigger();

      // propagated is for SOS only; delivered is for messages only.
      await env.deliver(env.ack(env.gateway, msg.id, AckStage.propagated));
      await env.deliver(env.ack(env.peer, sos.id, AckStage.delivered));
      expect(await statusOf(msg.id), MessageStatus.sentToGateway);
      expect(await sosStatusOf(sos.id), SosStatus.sentToGateway);

      // Only a gateway may report acknowledgement / propagation of an SOS.
      await env.deliver(env.ack(env.peer, sos.id, AckStage.gateway));
      await env.deliver(
        env.ack(env.peer, sos.id, AckStage.propagated, nodesReached: 5),
      );
      expect(await sosStatusOf(sos.id), SosStatus.sentToGateway);

      await env.deliver(env.ack(env.gateway, sos.id, AckStage.gateway));
      expect(await sosStatusOf(sos.id), SosStatus.acknowledged);
      await env.deliver(
        env.ack(env.gateway, sos.id, AckStage.propagated, nodesReached: 3),
      );
      final done = (await env.sosRepo.get(sos.id))!;
      expect(done.status, SosStatus.propagated);
      expect(done.nodesReached, 3);
    });

    test('stale SOS ACKs never move an SOS backwards or reopen it', () async {
      await env.startWithGateway();
      final sos = await env.sos.trigger();
      await env.deliver(
        env.ack(env.gateway, sos.id, AckStage.propagated, nodesReached: 2),
      );
      await env.deliver(env.ack(env.gateway, sos.id, AckStage.gateway)); // late
      expect(await sosStatusOf(sos.id), SosStatus.propagated);

      await env.sos.resolve(sos.id);
      await env.deliver(
        env.ack(env.gateway, sos.id, AckStage.propagated, nodesReached: 4),
      );
      final closed = (await env.sosRepo.get(sos.id))!;
      expect(closed.status, SosStatus.resolved);
      expect(closed.nodesReached, 2);
    });
  });

  group('gateway identity', () {
    test('a STATUS packet cannot promote a node to gateway', () async {
      env = FakeEnv(connected: false);
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );

      // The peer claims to be a gateway in a STATUS (only HELLO may do that).
      await env.deliver(
        env.peer.status(
          destinationId: FakeEnv.localNodeId,
          name: 'Totally a gateway',
          role: 'gateway',
        ),
      );
      expect(
        (await env.nodes.findByNodeId(FakeEnv.peerId))!.role,
        isNot(NodeRole.gateway),
      );

      // ...so its forged gateway-stage ACK must not be accepted.
      await env.deliver(env.ack(env.peer, sent.id, AckStage.gateway));
      expect(await statusOf(sent.id), MessageStatus.queued);
    });

    test('a STATUS packet cannot demote the gateway either', () async {
      await env.startWithGateway();
      await env.deliver(
        env.gateway.status(
          destinationId: FakeEnv.localNodeId,
          name: 'Gateway',
          role: 'traveller',
        ),
      );
      expect(
        (await env.nodes.findByNodeId(FakeEnv.gatewayId))!.role,
        NodeRole.gateway,
      );
    });

    test('HELLO is required before gateway ACKs are trusted', () async {
      env = FakeEnv(connected: false);
      await env.coordinator.start(); // no HELLO yet
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      await env.deliver(env.ack(env.gateway, sent.id, AckStage.gateway));
      expect(await statusOf(sent.id), MessageStatus.queued);
    });
  });

  group('malformed and invalid packets', () {
    test('invalid payloads are dropped, logged and change nothing', () async {
      env = FakeEnv(connected: false);
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      final nodesBefore = await env.nodeCount();
      final warningsBefore = await env.warningCount();

      final bad = <ProtocolMessage>[
        env.raw(ProtocolMessageType.ack, {'stage': 'delivered'}), // no ack_for
        env.raw(ProtocolMessageType.ack, {
          'ack_for': sent.id,
          'stage': 'teleported',
        }),
        env.raw(ProtocolMessageType.ack, {'ack_for': 5, 'stage': 'gateway'}),
        env.raw(ProtocolMessageType.status, {
          'battery': 150,
        }, source: 'ROGUE-1'),
        env.raw(ProtocolMessageType.status, {
          'battery': 'full',
        }, source: 'ROGUE-2'),
        env.raw(ProtocolMessageType.status, {'rssi': 20}, source: 'ROGUE-3'),
        env.raw(ProtocolMessageType.status, {
          'role': 'overlord',
        }, source: 'ROGUE-4'),
        env.raw(ProtocolMessageType.status, {
          'online': 'yes',
        }, source: 'ROGUE-5'),
        env.raw(ProtocolMessageType.hello, {
          'name': 'No role',
        }, source: 'ROGUE-6'),
        env.raw(ProtocolMessageType.text, {
          'note': 'no text',
        }, source: 'ROGUE-7'),
        env.raw(ProtocolMessageType.text, {
          'text': 'hi',
          'location': {'lat': 123, 'lon': 0},
        }, source: 'ROGUE-8'),
        env.raw(
          ProtocolMessageType.sos,
          {'sos_id': 'different'},
          source: 'ROGUE-9',
          destination: 'BROADCAST',
          messageId: 'sos-x',
        ),
        env.raw(
          ProtocolMessageType.sos,
          {'note': 'no id'},
          source: 'ROGUE-10',
          destination: 'BROADCAST',
        ),
        env.raw(ProtocolMessageType.error, {'code': 'x'}), // no ref
      ];
      for (final p in bad) {
        await env.deliver(p);
      }

      expect(await statusOf(sent.id), MessageStatus.queued);
      expect(await env.nodeCount(), nodesBefore); // no ROGUE-* nodes
      expect(await env.sosRepo.active(), isEmpty);
      expect((await env.messages.watchConversations().first), hasLength(1));
      expect(await env.warningCount(), warningsBefore + bad.length);
    });

    test(
      'STATUS readings are validated but valid ones update the node',
      () async {
        await env.startWithGateway();
        await env.deliver(
          env.peer.status(
            destinationId: FakeEnv.localNodeId,
            name: 'Peer',
            role: 'relay',
            batteryPercent: 55,
            rssi: -95,
          ),
        );
        final node = (await env.nodes.findByNodeId(FakeEnv.peerId))!;
        expect(node.batteryPercent, 55);
        expect(node.rssi, -95);
        expect(node.role, NodeRole.relay);
        expect(node.status, NodeStatus.online);
      },
    );

    test('TEXT for another node is not stored', () async {
      await env.startWithGateway();
      await env.deliver(
        env.peer.text(
          messageId: 'other',
          destinationId: 'SOMEONE-ELSE',
          body: 'psst',
        ),
      );
      expect(await env.messages.getMessage('other'), isNull);
    });

    test('a duplicate TEXT packet is stored once', () async {
      await env.startWithGateway();
      final packet = env.peer.text(
        messageId: 'dup-1',
        destinationId: FakeEnv.localNodeId,
        body: 'once',
      );
      await env.deliver(packet);
      await env.deliver(packet);
      final conv = (await env.messages.watchConversations().first).single;
      expect(await env.messages.watchMessages(conv.id).first, hasLength(1));
      expect(conv.unreadCount, 1);
    });
  });

  group('transmission errors', () {
    test('gateway ERROR fails a message once and retry resends it', () async {
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      final err = env.gateway.error(
        destinationId: FakeEnv.localNodeId,
        ref: sent.id,
        code: 'tx_failed',
        detail: 'radio busy',
      );
      await env.deliver(err);
      final failed = (await env.messages.getMessage(sent.id))!;
      expect(failed.status, MessageStatus.failed);
      expect(failed.failureReason, 'radio busy');

      final logs = (await env.logs()).length;
      await env.deliver(err); // duplicate
      expect((await env.logs()).length, logs);

      await env.messaging.retry(sent.id);
      expect(await statusOf(sent.id), MessageStatus.sentToGateway);
      expect(env.transport.sentMessages, hasLength(2));
    });

    test('ERROR cannot fail a delivered message', () async {
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      await env.deliver(env.ack(env.peer, sent.id, AckStage.delivered));
      await env.deliver(
        env.gateway.error(
          destinationId: FakeEnv.localNodeId,
          ref: sent.id,
          code: 'late',
        ),
      );
      expect(await statusOf(sent.id), MessageStatus.delivered);
    });

    test('ERROR from a non-gateway or for an unknown id is ignored', () async {
      await env.startWithGateway();
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      final sos = await env.sos.trigger();
      await env.deliver(
        env.peer.error(
          destinationId: FakeEnv.localNodeId,
          ref: sent.id,
          code: 'x',
        ),
      );
      await env.deliver(
        env.peer.error(
          destinationId: FakeEnv.localNodeId,
          ref: sos.id,
          code: 'x',
        ),
      );
      await env.deliver(
        env.gateway.error(
          destinationId: FakeEnv.localNodeId,
          ref: 'ghost',
          code: 'x',
        ),
      );
      expect(await statusOf(sent.id), MessageStatus.sentToGateway);
      expect(await sosStatusOf(sos.id), SosStatus.sentToGateway);
    });

    test(
      'gateway ERROR for an SOS marks the SOS failed, not a message',
      () async {
        await env.startWithGateway();
        final sos = await env.sos.trigger();
        expect(sos.status, SosStatus.sentToGateway);

        final err = env.gateway.error(
          destinationId: FakeEnv.localNodeId,
          ref: sos.id,
          code: 'tx_failed',
          detail: 'radio busy',
        );
        await env.deliver(err);
        var event = (await env.sosRepo.get(sos.id))!;
        expect(event.status, SosStatus.failed);
        expect(event.isActive, isTrue); // still needs attention
        expect(await env.messages.watchConversations().first, isEmpty);

        final logs = (await env.logs()).length;
        await env.deliver(err); // duplicate ERROR changes nothing
        expect((await env.logs()).length, logs);
        expect(await sosStatusOf(sos.id), SosStatus.failed);

        // Retry re-sends the same SOS id and moves it forward again.
        await env.sos.retry(sos.id);
        event = (await env.sosRepo.get(sos.id))!;
        expect(event.status, SosStatus.sentToGateway);
        expect(env.transport.sentSos.map((p) => p.messageId), [sos.id, sos.id]);
      },
    );

    test('a failed SOS is re-sent when the gateway reconnects', () async {
      await env.startWithGateway();
      final sos = await env.sos.trigger();
      await env.deliver(
        env.gateway.error(
          destinationId: FakeEnv.localNodeId,
          ref: sos.id,
          code: 'x',
        ),
      );
      env.transport.setState(TransportConnectionState.disconnected);
      await env.settle();
      env.transport.setState(TransportConnectionState.connected);
      await env.settle();
      expect(await sosStatusOf(sos.id), SosStatus.sentToGateway);
    });

    test(
      'an ACK after an SOS failure is explicit proof and moves it forward',
      () async {
        await env.startWithGateway();
        final sos = await env.sos.trigger();
        await env.deliver(
          env.gateway.error(
            destinationId: FakeEnv.localNodeId,
            ref: sos.id,
            code: 'x',
          ),
        );
        await env.deliver(env.ack(env.gateway, sos.id, AckStage.gateway));
        expect(await sosStatusOf(sos.id), SosStatus.acknowledged);
      },
    );

    test('an acknowledged SOS cannot be failed by a later ERROR', () async {
      await env.startWithGateway();
      final sos = await env.sos.trigger();
      await env.deliver(env.ack(env.gateway, sos.id, AckStage.gateway));
      await env.deliver(
        env.gateway.error(
          destinationId: FakeEnv.localNodeId,
          ref: sos.id,
          code: 'x',
        ),
      );
      expect(await sosStatusOf(sos.id), SosStatus.acknowledged);
    });

    test('a transport write failure fails the message with a reason', () async {
      await env.startWithGateway();
      env.transport.sendError = const TransportException('USB write failed');
      final sent = await env.messaging.send(
        peerNodeId: FakeEnv.peerId,
        body: 'hi',
      );
      expect(sent.status, MessageStatus.failed);
      expect(sent.failureReason, 'USB write failed');

      env.transport.sendError = null;
      await env.messaging.retry(sent.id);
      expect(await statusOf(sent.id), MessageStatus.sentToGateway);
    });

    test('a transport write failure leaves the SOS saved for retry', () async {
      await env.startWithGateway();
      env.transport.sendError = const TransportException('USB write failed');
      final sos = await env.sos.trigger();
      expect(sos.status, SosStatus.triggered);
      expect(env.transport.sentSos, isEmpty);

      env.transport.sendError = null;
      await env.sos.flushPending();
      expect(await sosStatusOf(sos.id), SosStatus.sentToGateway);
    });
  });
}
