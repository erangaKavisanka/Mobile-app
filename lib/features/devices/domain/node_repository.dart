import 'node.dart';

abstract class NodeRepository {
  Stream<List<Node>> watchNodes();
  Stream<Node?> watchNode(String id);
  Future<Node?> findByNodeId(String nodeId);

  /// Inserts or updates the node identified by [nodeId]. Null fields keep the
  /// stored value so a partial STATUS packet does not erase known readings.
  Future<Node> upsert({
    required String nodeId,
    String? name,
    NodeRole? role,
    NodeStatus? status,
    int? batteryPercent,
    int? rssi,
    DateTime? lastSeenAt,
    bool? isSimulated,
  });

  Future<void> markAllOffline({bool simulatedOnly = false});

  Stream<List<DeviceLog>> watchLogs({String? nodeId, int limit = 200});
  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    String? nodeRowId,
  });
}
