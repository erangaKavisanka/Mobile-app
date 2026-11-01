import 'package:ecolink/core/errors/app_exception.dart';
import 'package:ecolink/features/devices/domain/node.dart';
import 'package:ecolink/features/messaging/domain/message.dart';
import 'package:ecolink/features/synchronization/domain/sync_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  Future<Message> only() async {
    final conv = (await env.messages.watchConversations().first).single;
    return (await env.messages.watchMessages(conv.id).first).single;
  }

  test('offline send is saved, queued, and never claims delivery', () async {
    await env.coordinator.start();
    final sent = await env.messaging.send(
      peerNodeId: 'SIM-RELAY-B',
      body: 'hello',
    );
    expect(sent.status, MessageStatus.queued);
    expect(await env.messages.pendingCount(), 1);
    // A sync queue entry exists independently of delivery state.
    final sync = await env.sync.due();
    expect(sync.single.entityType, SyncEntityType.message);
  });

  test(
    'queued message is sent on connect and delivered only after ACK',
    () async {
      await env.coordinator.start();
      final sent = await env.messaging.send(
        peerNodeId: 'SIM-RELAY-B',
        body: 'hello',
      );
      expect(sent.status, MessageStatus.queued);

      await env.transport.connect();
      await env.until(
        () async =>
            (await only()).status == MessageStatus.sentToGateway ||
            (await only()).status == MessageStatus.delivered,
      );
      await env.until(
        () async => (await only()).status == MessageStatus.delivered,
      );
      expect((await only()).status, MessageStatus.delivered);
    },
  );

  test('connected send passes through sentToGateway to delivered', () async {
    await env.coordinator.start();
    await env.transport.connect();
    await env.until(
      () async => (await env.nodes.findByNodeId('GW-SIM-01')) != null,
    );
    final sent = await env.messaging.send(
      peerNodeId: 'SIM-RELAY-B',
      body: 'hello',
    );
    expect(sent.status, MessageStatus.sentToGateway);
    await env.until(
      () async => (await only()).status == MessageStatus.delivered,
    );
  });

  test(
    'gateway ERROR marks the message failed and retry recovers it',
    () async {
      final failing = TestEnv(failureRate: 1);
      addTearDown(failing.dispose);
      await failing.coordinator.start();
      await failing.transport.connect();
      final sent = await failing.messaging.send(
        peerNodeId: 'SIM-RELAY-B',
        body: 'x',
      );
      await failing.until(
        () async =>
            (await failing.messages.getMessage(sent.id))!.status ==
            MessageStatus.failed,
      );
      final failed = (await failing.messages.getMessage(sent.id))!;
      expect(failed.failureReason, isNotNull);

      await failing.messaging.retry(sent.id);
      final again = (await failing.messages.getMessage(sent.id))!;
      expect(again.status, MessageStatus.sentToGateway);
    },
  );

  test('unroutable destination fails instead of staying pending', () async {
    await env.coordinator.start();
    await env.transport.connect();
    final sent = await env.messaging.send(peerNodeId: 'NOBODY', body: 'x');
    await env.until(
      () async =>
          (await env.messages.getMessage(sent.id))!.status ==
          MessageStatus.failed,
    );
  });

  test('an interrupted `local` message is recovered on start', () async {
    final conv = await env.messages.getOrCreateConversation('SIM-RELAY-B');
    final now = DateTime.now();
    await env.messages.insertMessage(
      Message(
        id: 'stuck',
        conversationId: conv.id,
        senderNodeId: env.localNodeId,
        recipientNodeId: 'SIM-RELAY-B',
        body: 'x',
        direction: MessageDirection.outgoing,
        status: MessageStatus.local,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await env.coordinator.start();
    expect(
      (await env.messages.getMessage('stuck'))!.status,
      MessageStatus.queued,
    );
  });

  test('empty and oversized messages are rejected before storage', () async {
    expect(
      () => env.messaging.send(peerNodeId: 'B', body: '   '),
      throwsA(isA<ValidationException>()),
    );
    expect(
      () => env.messaging.send(peerNodeId: 'B', body: 'x' * 600),
      throwsA(isA<ValidationException>()),
    );
    expect(await env.messages.watchConversations().first, isEmpty);
  });

  test(
    'incoming message creates a conversation, counts unread, and dedupes',
    () async {
      await env.coordinator.start();
      await env.transport.connect();
      await env.until(
        () async => (await env.nodes.findByNodeId('SIM-RELAY-B')) != null,
      );
      await env.transport.simulateIncomingMessage();
      await env.until(
        () async => (await env.messages.watchConversations().first).isNotEmpty,
      );

      final conv = (await env.messages.watchConversations().first).single;
      expect(conv.unreadCount, 1);
      final msg = (await env.messages.watchMessages(conv.id).first).single;
      expect(msg.direction, MessageDirection.incoming);
      expect(msg.status, MessageStatus.delivered); // it arrived; nothing to ack

      // Re-processing the same packet id must not duplicate it.
      expect(await env.messages.insertMessage(msg), isFalse);
      expect(await env.messages.watchMessages(conv.id).first, hasLength(1));

      await env.messages.markConversationRead(conv.id);
      expect(
        (await env.messages.watchConversations().first).single.unreadCount,
        0,
      );
    },
  );

  test('search finds text and treats wildcards literally', () async {
    final conv = await env.messages.getOrCreateConversation('B');
    Future<void> add(String id, String body) => env.messages.insertMessage(
      Message(
        id: id,
        conversationId: conv.id,
        senderNodeId: 'B',
        recipientNodeId: 'me',
        body: body,
        direction: MessageDirection.incoming,
        status: MessageStatus.delivered,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await add('1', 'River crossing is flooded');
    await add('2', '100% sure');
    expect((await env.messages.search('river')).map((m) => m.id), ['1']);
    expect((await env.messages.search('%')).map((m) => m.id), ['2']);
    expect(await env.messages.search('  '), isEmpty);
  });

  test('disconnect marks nodes offline', () async {
    await env.coordinator.start();
    await env.transport.connect();
    await env.until(
      () async => (await env.nodes.findByNodeId('SIM-RELAY-B')) != null,
    );
    expect(
      (await env.nodes.findByNodeId('SIM-RELAY-B'))!.status,
      NodeStatus.online,
    );
    await env.transport.disconnect();
    await env.until(
      () async =>
          (await env.nodes.findByNodeId('SIM-RELAY-B'))!.status ==
          NodeStatus.offline,
    );
  });
}
