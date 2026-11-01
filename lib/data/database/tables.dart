import 'package:drift/drift.dart';

import '../../features/devices/domain/node.dart';
import '../../features/messaging/domain/message.dart';
import '../../features/sos/domain/sos_event.dart';
import '../../features/synchronization/domain/sync_item.dart';

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get nodeId => text().unique()();
  BoolColumn get isLocal => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NodeRow')
class Nodes extends Table {
  TextColumn get id => text()();
  TextColumn get nodeId => text().unique()();
  TextColumn get name => text()();
  TextColumn get role => textEnum<NodeRole>()();
  TextColumn get status => textEnum<NodeStatus>()();
  IntColumn get batteryPercent => integer().nullable()();
  IntColumn get rssi => integer().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  BoolColumn get isSimulated => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ConversationRow')
class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get peerNodeId => text().unique().references(Nodes, #nodeId)();
  TextColumn get title => text()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(
  name: 'messages_conversation_time',
  columns: {#conversationId, #createdAt},
)
@TableIndex(name: 'messages_status', columns: {#status})
@DataClassName('MessageRow')
class Messages extends Table {
  /// Also the protocol message_id; the primary key makes duplicates impossible.
  TextColumn get id => text()();
  TextColumn get conversationId =>
      text().references(Conversations, #id, onDelete: KeyAction.cascade)();
  TextColumn get senderNodeId => text()();
  TextColumn get recipientNodeId => text()();
  TextColumn get body => text()();
  TextColumn get direction => textEnum<MessageDirection>()();
  TextColumn get status => textEnum<MessageStatus>()();
  TextColumn get failureReason => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get locationAccuracy => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'sos_events_status', columns: {#status})
@DataClassName('SosEventRow')
class SosEvents extends Table {
  TextColumn get id => text()();
  TextColumn get sourceNodeId => text()();
  TextColumn get status => textEnum<SosStatus>()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get nodesReached => integer().withDefault(const Constant(0))();
  BoolColumn get isSimulated => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  DateTimeColumn get acknowledgedAt => dateTime().nullable()();
  DateTimeColumn get propagatedAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'location_records_time', columns: {#recordedAt})
@DataClassName('LocationRow')
class LocationRecords extends Table {
  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get accuracy => real().nullable()();
  RealColumn get altitude => real().nullable()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'sync_queue_status', columns: {#status, #createdAt})
@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => textEnum<SyncEntityType>()();
  TextColumn get entityId => text()();
  TextColumn get operation => textEnum<SyncOperation>()();
  TextColumn get payload => text()();
  TextColumn get status => textEnum<SyncStatus>()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {entityType, entityId, operation},
  ];
}

@TableIndex(name: 'device_logs_time', columns: {#createdAt})
@DataClassName('DeviceLogRow')
class DeviceLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nodeId =>
      text().nullable().references(Nodes, #id, onDelete: KeyAction.setNull)();
  TextColumn get level => textEnum<LogLevel>()();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
