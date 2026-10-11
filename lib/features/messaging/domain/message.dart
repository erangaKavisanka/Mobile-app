class Conversation {
  Conversation({
    required this.id,
    required this.peerId,
    required this.title,
    required this.messages,
  });

  final String id;
  final String peerId;
  final String title;
  final List<ChatMessage> messages;
}

enum MessageLifecycleStatus {
  queuedLocally,
  sentToDevice,
  receivedByDestination,
  failed,
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    required this.lifecycleStatus,
  });

  final String id;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  MessageLifecycleStatus lifecycleStatus;

  String get peerId => senderId == 'NODE_A' ? recipientId : senderId;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      lifecycleStatus: MessageLifecycleStatus.values.firstWhere(
        (status) => status.name == json['lifecycleStatus'],
        orElse: () => MessageLifecycleStatus.queuedLocally,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'recipientId': recipientId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'lifecycleStatus': lifecycleStatus.name,
  };
}
