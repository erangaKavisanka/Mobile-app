import 'message.dart';

abstract class MessageRepository {
  Stream<List<Conversation>> watchConversations();
  Stream<Conversation?> watchConversation(String conversationId);
  Stream<List<Message>> watchMessages(String conversationId);
  Future<List<Message>> search(String query);

  /// Returns the conversation with [peerNodeId], creating it when needed.
  Future<Conversation> getOrCreateConversation(
    String peerNodeId, {
    String? title,
  });

  Future<Message?> getMessage(String id);

  /// Inserts a message. Returns false (and changes nothing) when a message
  /// with the same id already exists, which prevents duplicate processing.
  Future<bool> insertMessage(Message message, {bool enqueueSync = false});

  Future<void> updateStatus(
    String messageId,
    MessageStatus status, {
    String? failureReason,
  });

  Future<List<Message>> outgoingWithStatus(Set<MessageStatus> statuses);
  Future<void> markConversationRead(String conversationId);
  Future<int> pendingCount();
}
