/// Lifecycle of an SOS event.
///
/// triggered -> sentToGateway -> acknowledged -> propagated -> resolved
/// An event can be cancelled (triggered in error) or resolved from any
/// active state. If the gateway reports a transmission error the event
/// becomes `failed` (still active) and is re-sent by retry / on reconnect.
enum SosStatus {
  triggered,
  failed,
  sentToGateway,
  acknowledged,
  propagated,
  resolved,
  cancelled;

  bool get isActive =>
      this != SosStatus.resolved && this != SosStatus.cancelled;
}

class SosEvent {
  const SosEvent({
    required this.id,
    required this.sourceNodeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.note,
    this.sentAt,
    this.acknowledgedAt,
    this.propagatedAt,
    this.closedAt,
    this.nodesReached = 0,
    this.isSimulated = false,
  });

  final String id;
  final String sourceNodeId;
  final SosStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? note;
  final DateTime? sentAt;
  final DateTime? acknowledgedAt;
  final DateTime? propagatedAt;
  final DateTime? closedAt;
  final int nodesReached;

  /// True when the acknowledgement/propagation came from the simulated
  /// transport rather than real hardware.
  final bool isSimulated;

  bool get isActive => status.isActive;
  bool get hasLocation => latitude != null && longitude != null;
}
