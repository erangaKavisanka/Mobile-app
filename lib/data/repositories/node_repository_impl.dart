import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../features/devices/domain/node.dart';
import '../../features/devices/domain/node_repository.dart';
import '../database/app_database.dart';

class NodeRepositoryImpl implements NodeRepository {
  NodeRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _ids = IdGenerator();

  Node _toNode(NodeRow r) => Node(
    id: r.id,
    nodeId: r.nodeId,
    name: r.name,
    role: r.role,
    status: r.status,
    batteryPercent: r.batteryPercent,
    rssi: r.rssi,
    lastSeenAt: r.lastSeenAt,
    isSimulated: r.isSimulated,
  );

  @override
  Stream<List<Node>> watchNodes() {
    final q = _db.select(_db.nodes)
      ..orderBy([
        (t) => OrderingTerm.asc(t.role),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return q.watch().map((rows) => rows.map(_toNode).toList());
  }

  @override
  Stream<Node?> watchNode(String id) {
    final q = _db.select(_db.nodes)..where((t) => t.id.equals(id));
    return q.watchSingleOrNull().map((r) => r == null ? null : _toNode(r));
  }

  @override
  Future<Node?> findByNodeId(String nodeId) async {
    final row = await (_db.select(
      _db.nodes,
    )..where((t) => t.nodeId.equals(nodeId))).getSingleOrNull();
    return row == null ? null : _toNode(row);
  }

  @override
  Future<Node> upsert({
    required String nodeId,
    String? name,
    NodeRole? role,
    NodeStatus? status,
    int? batteryPercent,
    int? rssi,
    DateTime? lastSeenAt,
    bool? isSimulated,
  }) {
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.nodes,
      )..where((t) => t.nodeId.equals(nodeId))).getSingleOrNull();
      if (existing == null) {
        final row = NodesCompanion.insert(
          id: _ids.next(),
          nodeId: nodeId,
          name: name ?? nodeId,
          role: role ?? NodeRole.traveller,
          status: status ?? NodeStatus.unknown,
          batteryPercent: Value(batteryPercent),
          rssi: Value(rssi),
          lastSeenAt: Value(lastSeenAt),
          isSimulated: Value(isSimulated ?? false),
        );
        final inserted = await _db.into(_db.nodes).insertReturning(row);
        return _toNode(inserted);
      }
      final updated =
          await (_db.update(
            _db.nodes,
          )..where((t) => t.id.equals(existing.id))).writeReturning(
            NodesCompanion(
              name: Value.absentIfNull(name),
              role: Value.absentIfNull(role),
              status: Value.absentIfNull(status),
              batteryPercent: Value.absentIfNull(batteryPercent),
              rssi: Value.absentIfNull(rssi),
              lastSeenAt: Value.absentIfNull(lastSeenAt),
              isSimulated: Value.absentIfNull(isSimulated),
            ),
          );
      return _toNode(updated.single);
    });
  }

  @override
  Future<void> markAllOffline({bool simulatedOnly = false}) async {
    final q = _db.update(_db.nodes);
    if (simulatedOnly) q.where((t) => t.isSimulated.equals(true));
    await q.write(const NodesCompanion(status: Value(NodeStatus.offline)));
  }

  @override
  Stream<List<DeviceLog>> watchLogs({String? nodeId, int limit = 200}) {
    final q = _db.select(_db.deviceLogs)
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(limit);
    if (nodeId != null) q.where((t) => t.nodeId.equals(nodeId));
    return q.watch().map(
      (rows) => rows
          .map(
            (r) => DeviceLog(
              id: r.id,
              nodeId: r.nodeId,
              level: r.level,
              message: r.message,
              createdAt: r.createdAt,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    String? nodeRowId,
  }) async {
    await _db
        .into(_db.deviceLogs)
        .insert(
          DeviceLogsCompanion.insert(
            level: level,
            message: message,
            createdAt: _clock(),
            nodeId: Value(nodeRowId),
          ),
        );
  }
}
