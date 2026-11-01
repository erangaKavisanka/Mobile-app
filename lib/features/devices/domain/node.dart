enum NodeRole { gateway, relay, traveller }

enum NodeStatus { online, offline, unknown }

class Node {
  const Node({
    required this.id,
    required this.nodeId,
    required this.name,
    required this.role,
    required this.status,
    this.batteryPercent,
    this.rssi,
    this.lastSeenAt,
    this.isSimulated = false,
  });

  final String id;

  /// Protocol-level identity (e.g. `GW-SIM-01`).
  final String nodeId;
  final String name;
  final NodeRole role;
  final NodeStatus status;
  final int? batteryPercent;
  final int? rssi;
  final DateTime? lastSeenAt;
  final bool isSimulated;

  bool get isGateway => role == NodeRole.gateway;
}

enum LogLevel { info, warning, error }

class DeviceLog {
  const DeviceLog({
    required this.id,
    required this.level,
    required this.message,
    required this.createdAt,
    this.nodeId,
  });

  final int id;
  final LogLevel level;
  final String message;
  final DateTime createdAt;

  /// Row id of the related [Node], if any.
  final String? nodeId;
}
