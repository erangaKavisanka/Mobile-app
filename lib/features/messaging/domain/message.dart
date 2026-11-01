/// Delivery lifecycle of a message. Cloud synchronization is tracked
/// separately in the sync queue and never changes this status.
enum MessageStatus {
  /// Persisted on this phone only; not yet accepted by the outbound queue.
  local,

  /// Waiting for a gateway connection.
  queued,

  /// Handed to the gateway. This is NOT proof of delivery.
  sentToGateway,

  /// An explicit acknowledgement (real or simulated) was received.
  delivered,

  /// Sending failed or the gateway reported an error.
  failed;

  bool get isPending =>
      this == MessageStatus.local ||
      this == MessageStatus.queued ||
      this == MessageStatus.sentToGateway;
}

enum MessageDirection { incoming, outgoing }

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderNodeId,
    required this.recipientNodeId,
    required this.body,
    required this.direction,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.failureReason,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
  });

  /// Doubles as the protocol `message_id`, so retries and duplicates from the
  /// device can be matched to a single row.
  final String id;
  final String conversationId;
  final String senderNodeId;
  final String recipientNodeId;
  final String body;
  final MessageDirection direction;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? failureReason;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;

  bool get isOutgoing => direction == MessageDirection.outgoing;
  bool get hasLocation => latitude != null && longitude != null;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.peerNodeId,
    required this.title,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final String peerNodeId;
  final String title;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
}
