import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../features/messaging/domain/message.dart';
import '../../features/devices/domain/node.dart';
import '../../features/messaging/domain/message_repository.dart';
import '../../features/synchronization/domain/sync_item.dart';
import '../database/app_database.dart';
import 'sync_queue_writer.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _ids = IdGenerator();

  Message _toMessage(MessageRow r) => Message(
    id: r.id,
    conversationId: r.conversationId,
    senderNodeId: r.senderNodeId,
    recipientNodeId: r.recipientNodeId,
    body: r.body,
    direction: r.direction,
    status: r.status,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    failureReason: r.failureReason,
    latitude: r.latitude,
    longitude: r.longitude,
    locationAccuracy: r.locationAccuracy,
  );

  @override
  Stream<List<Conversation>> watchConversations() {
    final lastAt = _db.messages.createdAt.max();
    final query = _db.select(_db.conversations).join([
      leftOuterJoin(
        _db.messages,
        _db.messages.conversationId.equalsExp(_db.conversations.id),
      ),
    ]);
    // Latest message per conversation is resolved below; the join keeps the
    // stream reactive to both tables.
    query.addColumns([lastAt]);
    query.groupBy([_db.conversations.id]);
    return query.watch().asyncMap((rows) async {
      final result = <Conversation>[];
      for (final row in rows) {
        final c = row.readTable(_db.conversations);
        final last =
            await (_db.select(_db.messages)
                  ..where((m) => m.conversationId.equals(c.id))
                  ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
                  ..limit(1))
                .getSingleOrNull();
        result.add(_toConversation(c, last));
      }
      result.sort(
        (a, b) => (b.lastMessageAt ?? b.createdAt).compareTo(
          a.lastMessageAt ?? a.createdAt,
        ),
      );
      return result;
    });
  }

  Conversation _toConversation(ConversationRow c, MessageRow? last) {
    return Conversation(
      id: c.id,
      peerNodeId: c.peerNodeId,
      title: c.title,
      createdAt: c.createdAt,
      unreadCount: c.unreadCount,
      lastMessage: last?.body,
      lastMessageAt: last?.createdAt,
    );
  }

  @override
  Stream<Conversation?> watchConversation(String conversationId) {
    final q = _db.select(_db.conversations)
      ..where((t) => t.id.equals(conversationId));
    return q.watchSingleOrNull().map(
      (c) => c == null ? null : _toConversation(c, null),
    );
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final q = _db.select(_db.messages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_toMessage).toList());
  }

  @override
  Future<List<Message>> search(String query) async {
    final term = query.trim();
    if (term.isEmpty) return const [];
    final escaped = term
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final rows =
        await (_db.select(_db.messages)
              ..where((t) => t.body.like('%$escaped%', escapeChar: r'\'))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(100))
            .get();
    return rows.map(_toMessage).toList();
  }

  @override
  Future<Conversation> getOrCreateConversation(
    String peerNodeId, {
    String? title,
  }) {
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.conversations,
      )..where((t) => t.peerNodeId.equals(peerNodeId))).getSingleOrNull();
      if (existing != null) return _toConversation(existing, null);

      // The conversation references the peer node row, so make sure it exists.
      await _db
          .into(_db.nodes)
          .insert(
            NodesCompanion.insert(
              id: _ids.next(),
              nodeId: peerNodeId,
              name: title ?? peerNodeId,
              role: NodeRole.traveller,
              status: NodeStatus.unknown,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      final node = await (_db.select(
        _db.nodes,
      )..where((t) => t.nodeId.equals(peerNodeId))).getSingle();
      final row = await _db
          .into(_db.conversations)
          .insertReturning(
            ConversationsCompanion.insert(
              id: _ids.next(),
              peerNodeId: peerNodeId,
              title: title ?? node.name,
              createdAt: _clock(),
            ),
          );
      return _toConversation(row, null);
    });
  }

  @override
  Future<Message?> getMessage(String id) async {
    final row = await (_db.select(
      _db.messages,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toMessage(row);
  }

  @override
  Future<bool> insertMessage(Message m, {bool enqueueSync = false}) {
    return _db.transaction(() async {
      final inserted = await _db
          .into(_db.messages)
          .insertReturningOrNull(
            MessagesCompanion.insert(
              id: m.id,
              conversationId: m.conversationId,
              senderNodeId: m.senderNodeId,
              recipientNodeId: m.recipientNodeId,
              body: m.body,
              direction: m.direction,
              status: m.status,
              createdAt: m.createdAt,
              updatedAt: m.updatedAt,
              failureReason: Value(m.failureReason),
              latitude: Value(m.latitude),
              longitude: Value(m.longitude),
              locationAccuracy: Value(m.locationAccuracy),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      // null means the row already existed and was ignored.
      if (inserted == null) return false;

      if (m.direction == MessageDirection.incoming) {
        await _db.customUpdate(
          'UPDATE conversations SET unread_count = unread_count + 1 '
          'WHERE id = ?',
          variables: [Variable.withString(m.conversationId)],
          updates: {_db.conversations},
        );
      }
      if (enqueueSync) {
        await _db.enqueueSync(
          SyncEntityType.message,
          m.id,
          SyncOperation.create,
          jsonEncode({
            'id': m.id,
            'sender': m.senderNodeId,
            'recipient': m.recipientNodeId,
            'body': m.body,
            'direction': m.direction.name,
            'created_at': m.createdAt.toUtc().toIso8601String(),
            if (m.hasLocation)
              'location': {'lat': m.latitude, 'lon': m.longitude},
          }),
        );
      }
      return true;
    });
  }

  @override
  Future<void> updateStatus(
    String messageId,
    MessageStatus status, {
    String? failureReason,
  }) async {
    await (_db.update(
      _db.messages,
    )..where((t) => t.id.equals(messageId))).write(
      MessagesCompanion(
        status: Value(status),
        updatedAt: Value(_clock()),
        failureReason: Value(
          status == MessageStatus.failed ? failureReason : null,
        ),
      ),
    );
  }

  @override
  Future<List<Message>> outgoingWithStatus(Set<MessageStatus> statuses) async {
    final rows =
        await (_db.select(_db.messages)
              ..where(
                (t) =>
                    t.direction.equalsValue(MessageDirection.outgoing) &
                    t.status.isInValues(statuses.toList()),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map(_toMessage).toList();
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    await (_db.update(_db.conversations)
          ..where((t) => t.id.equals(conversationId)))
        .write(const ConversationsCompanion(unreadCount: Value(0)));
  }

  @override
  Future<int> pendingCount() async {
    final count = _db.messages.id.count();
    final q = _db.selectOnly(_db.messages)
      ..addColumns([count])
      ..where(
        _db.messages.direction.equalsValue(MessageDirection.outgoing) &
            _db.messages.status.isInValues([
              MessageStatus.local,
              MessageStatus.queued,
              MessageStatus.sentToGateway,
            ]),
      );
    return (await q.getSingle()).read(count) ?? 0;
  }
}
