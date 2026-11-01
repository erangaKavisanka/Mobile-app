import 'dart:io';

import 'package:drift/native.dart';
import 'package:ecolink/core/protocol/protocol_factory.dart';
import 'package:ecolink/data/database/app_database.dart';
import 'package:ecolink/features/devices/domain/device_transport.dart';
import 'package:ecolink/features/messaging/domain/message.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_env.dart';
import '../support/test_env.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    allowMultipleDatabases();
    dir = Directory.systemTemp.createTempSync('ecolink_restart_');
    file = File('${dir.path}/ecolink.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  AppDatabase open() => AppDatabase(NativeDatabase(file));

  test('queued messages and SOS survive a restart and are sent on connect', () async {
    // --- first run: offline ---
    final first = FakeEnv(database: open(), connected: false);
    await first.startWithGateway();
    final queued = await first.messaging.send(
      peerNodeId: FakeEnv.peerId,
      body: 'queued before restart',
    );
    final sos = await first.sos.trigger();
    // A message the app was killed on before it could be queued.
    final conv = await first.messages.getOrCreateConversation(FakeEnv.peerId);
    final now = DateTime.now();
    await first.messages.insertMessage(
      Message(
        id: 'stuck-local',
        conversationId: conv.id,
        senderNodeId: FakeEnv.localNodeId,
        recipientNodeId: FakeEnv.peerId,
        body: 'stuck in local',
        direction: MessageDirection.outgoing,
        status: MessageStatus.local,
        createdAt: now,
        updatedAt: now,
      ),
      enqueueSync: true,
    );
    expect(queued.status, MessageStatus.queued);
    expect(sos.status, SosStatus.triggered);
    await first.dispose();

    // --- second run: same database file, still offline ---
    final second = FakeEnv(database: open(), connected: false);
    addTearDown(second.dispose);
    await second.coordinator.start();

    expect(
      (await second.messages.getMessage(queued.id))!.status,
      MessageStatus.queued,
    );
    expect(
      (await second.messages.getMessage('stuck-local'))!.status,
      MessageStatus.queued, // recovered from `local`
    );
    expect((await second.sosRepo.get(sos.id))!.status, SosStatus.triggered);
    expect(await second.sync.due(ignoreBackoff: true), hasLength(3));
    expect(second.transport.sentMessages, isEmpty);
    expect(second.transport.sentSos, isEmpty);

    // --- the gateway comes up: everything pending goes out, nothing twice ---
    second.transport.setState(TransportConnectionState.connected);
    await second.settle();
    expect(
      second.transport.sentMessages.map((p) => p.messageId),
      unorderedEquals([queued.id, 'stuck-local']),
    );
    expect(second.transport.sentSos.map((p) => p.messageId), [sos.id]);
    expect(
      (await second.messages.getMessage(queued.id))!.status,
      MessageStatus.sentToGateway,
    );
    expect((await second.sosRepo.get(sos.id))!.status, SosStatus.sentToGateway);

    // Delivery is still only proven by an ACK from the recipient.
    await second.deliver(
      second.gateway.hello(
        destinationId: FakeEnv.localNodeId,
        name: 'GW',
        role: 'gateway',
      ),
    );
    await second.deliver(
      second.ack(second.peer, queued.id, AckStage.delivered),
    );
    expect(
      (await second.messages.getMessage(queued.id))!.status,
      MessageStatus.delivered,
    );
    expect(
      (await second.messages.getMessage('stuck-local'))!.status,
      MessageStatus.sentToGateway,
    );
  });

  test('reconnecting twice does not resend already-sent messages', () async {
    final env = FakeEnv(database: open(), connected: false);
    addTearDown(env.dispose);
    await env.coordinator.start();
    final sent = await env.messaging.send(
      peerNodeId: FakeEnv.peerId,
      body: 'once',
    );

    env.transport.setState(TransportConnectionState.connected);
    await env.settle();
    env.transport.setState(TransportConnectionState.disconnected);
    await env.settle();
    env.transport.setState(TransportConnectionState.connected);
    await env.settle();

    expect(
      env.transport.sentMessages.where((p) => p.messageId == sent.id),
      hasLength(1),
    );
  });
}
