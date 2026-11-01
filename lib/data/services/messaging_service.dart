import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/protocol/protocol.dart';
import '../../core/protocol/protocol_factory.dart';
import '../../core/utils/id_generator.dart';
import '../../features/devices/domain/device_transport.dart';
import '../../features/devices/domain/node_repository.dart';
import '../../features/location/domain/location_fix.dart';
import '../../features/messaging/domain/message.dart';
import '../../features/messaging/domain/message_repository.dart';

/// Owns the message lifecycle: local -> queued -> sentToGateway -> delivered/failed.
///
/// `delivered` is only ever set from [markDelivered], which the gateway
/// coordinator calls when an ACK packet arrives.
class MessagingService {
  MessagingService({
    required MessageRepository messages,
    required NodeRepository nodes,
    required DeviceTransport transport,
    required ProtocolFactory protocol,
    IdGenerator ids = const IdGenerator(),
    DateTime Function()? clock,
  }) : _messages = messages,
       _nodes = nodes,
       _transport = transport,
       _protocol = protocol,
       _ids = ids,
       _clock = clock ?? DateTime.now;

  final MessageRepository _messages;
  final NodeRepository _nodes;
  final DeviceTransport _transport;
  final ProtocolFactory _protocol;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  String get localNodeId => _protocol.localNodeId;

  bool get _linkUp =>
      _transport.currentState == TransportConnectionState.connected;

  ProtocolMessage _toPacket(Message m) => _protocol.text(
    messageId: m.id,
    destinationId: m.recipientNodeId,
    body: m.body,
    latitude: m.latitude,
    longitude: m.longitude,
    accuracy: m.locationAccuracy,
  );

  /// Saves the message locally, queues it, and transmits if the gateway is up.
  /// Returns the stored message in its resulting state.
  Future<Message> send({
    required String peerNodeId,
    required String body,
    LocationFix? location,
  }) async {
    final text = body.trim();
    if (text.isEmpty) {
      throw const ValidationException('Message cannot be empty.');
    }
    final id = _ids.next();
    final probe = _protocol.text(
      messageId: id,
      destinationId: peerNodeId,
      body: text,
      latitude: location?.latitude,
      longitude: location?.longitude,
      accuracy: location?.accuracy,
    );
    if (probe.encodedLength > AppConstants.maxMessageBytes) {
      throw const ValidationException(
        'Message is too long for the radio link '
        '(limit ${AppConstants.maxMessageBytes} bytes).',
      );
    }

    final conversation = await _messages.getOrCreateConversation(peerNodeId);
    final now = _clock();
    final draft = Message(
      id: id,
      conversationId: conversation.id,
      senderNodeId: localNodeId,
      recipientNodeId: peerNodeId,
      body: text,
      direction: MessageDirection.outgoing,
      status: MessageStatus.local,
      createdAt: now,
      updatedAt: now,
      latitude: location?.latitude,
      longitude: location?.longitude,
      locationAccuracy: location?.accuracy,
    );

    await _messages.insertMessage(draft, enqueueSync: true);
    await _messages.updateStatus(draft.id, MessageStatus.queued);
    if (_linkUp) await _transmit(draft.id);
    return (await _messages.getMessage(draft.id))!;
  }

  /// Sends one stored message. Messages stay `queued` if the link is down.
  Future<void> _transmit(String id) async {
    final message = await _messages.getMessage(id);
    if (message == null || !message.isOutgoing) return;
    try {
      await _transport.sendMessage(_toPacket(message));
      await _messages.updateStatus(id, MessageStatus.sentToGateway);
    } on TransportException catch (e) {
      await _messages.updateStatus(
        id,
        MessageStatus.failed,
        failureReason: e.message,
      );
    }
  }

  /// Re-queues a failed message and sends it if the gateway is connected.
  Future<void> retry(String messageId) async {
    final message = await _messages.getMessage(messageId);
    if (message == null || message.status != MessageStatus.failed) return;
    await _messages.updateStatus(messageId, MessageStatus.queued);
    if (_linkUp) await _transmit(messageId);
  }

  /// Sends everything waiting in the queue. Also recovers `local` messages
  /// left behind if the app was killed between saving and queueing.
  Future<void> flushQueue() async {
    final waiting = await _messages.outgoingWithStatus({
      MessageStatus.local,
      MessageStatus.queued,
    });
    // Recover every `local` message first, even when the link is down.
    for (final m in waiting.where((m) => m.status == MessageStatus.local)) {
      await _messages.updateStatus(m.id, MessageStatus.queued);
    }
    for (final m in waiting) {
      if (!_linkUp) return;
      await _transmit(m.id);
    }
  }

  /// The outgoing message with [id], or null if there is none (incoming
  /// messages are never acknowledgement targets).
  Future<Message?> findOutgoing(String id) async {
    final message = await _messages.getMessage(id);
    return message != null && message.isOutgoing ? message : null;
  }

  /// Marks an outgoing message delivered. Called only for a validated ACK.
  /// A late ACK also upgrades a `failed` message: it is explicit evidence.
  /// Returns false when nothing changed (duplicate or unknown).
  Future<bool> markDelivered(String messageId) async {
    final message = await findOutgoing(messageId);
    if (message == null || message.status == MessageStatus.delivered) {
      return false;
    }
    await _messages.updateStatus(messageId, MessageStatus.delivered);
    return true;
  }

  /// Records that the gateway accepted a message we had not yet marked as
  /// sent (e.g. the app stopped between the write and the status update).
  /// Never downgrades `delivered` and never resurrects a `failed` message.
  Future<bool> markGatewayAccepted(String messageId) async {
    final message = await findOutgoing(messageId);
    if (message == null ||
        (message.status != MessageStatus.local &&
            message.status != MessageStatus.queued)) {
      return false;
    }
    await _messages.updateStatus(messageId, MessageStatus.sentToGateway);
    return true;
  }

  /// Marks a not-yet-delivered outgoing message failed. Returns false for
  /// delivered, already-failed or unknown messages.
  Future<bool> markFailed(String messageId, String reason) async {
    final message = await findOutgoing(messageId);
    if (message == null ||
        message.status == MessageStatus.delivered ||
        message.status == MessageStatus.failed) {
      return false;
    }
    await _messages.updateStatus(
      messageId,
      MessageStatus.failed,
      failureReason: reason,
    );
    return true;
  }

  /// Stores an incoming TEXT packet. Returns false for duplicates and for
  /// packets addressed to some other node.
  Future<bool> receive(ProtocolMessage packet) async {
    final forUs =
        packet.destinationId == localNodeId ||
        packet.destinationId == AppConstants.broadcastId;
    if (!forUs) return false;

    final body = packet.requireString('text');
    final sender = await _nodes.findByNodeId(packet.sourceId);
    final conversation = await _messages.getOrCreateConversation(
      packet.sourceId,
      title: sender?.name,
    );
    final location = packet.location;
    return _messages.insertMessage(
      Message(
        id: packet.messageId,
        conversationId: conversation.id,
        senderNodeId: packet.sourceId,
        recipientNodeId: localNodeId,
        body: body,
        direction: MessageDirection.incoming,
        status: MessageStatus.delivered,
        createdAt: packet.createdAt,
        updatedAt: _clock(),
        latitude: location?.lat,
        longitude: location?.lon,
        locationAccuracy: location?.accuracy,
      ),
    );
  }
}
