enum SyncStatus { pending, inProgress, synced, failed }

enum SyncEntityType { message, sosEvent }

enum SyncOperation { create, update }

class SyncItem {
  const SyncItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.lastError,
    this.lastAttemptAt,
    this.syncedAt,
  });

  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;

  /// JSON snapshot of the entity at enqueue time.
  final String payload;
  final SyncStatus status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? syncedAt;

  /// Identifies the remote event. Re-sending the same item (a retry after a
  /// lost response, say) must overwrite, not duplicate, the remote record.
  String get idempotencyKey => '${entityType.name}:$entityId:${operation.name}';

  /// Entity this item belongs to. Items of one entity are uploaded in order.
  String get entityKey => '${entityType.name}:$entityId';

  /// Earliest time a `failed` item may be retried automatically.
  DateTime? get nextAttemptAt {
    final last = lastAttemptAt;
    if (status != SyncStatus.failed || last == null) return null;
    return last.add(SyncBackoff.delayFor(retryCount));
  }
}

/// Exponential retry delay: 30 s, 1 min, 2 min ... capped at 1 hour.
class SyncBackoff {
  SyncBackoff._();

  static const base = Duration(seconds: 30);
  static const max = Duration(hours: 1);

  static Duration delayFor(int retryCount) {
    if (retryCount <= 0) return Duration.zero;
    final exponent = (retryCount - 1).clamp(0, 12);
    final delay = base * (1 << exponent);
    return delay > max ? max : delay;
  }
}

class SyncSummary {
  const SyncSummary({
    this.pending = 0,
    this.failed = 0,
    this.synced = 0,
    this.lastSyncedAt,
    this.lastError,
  });

  final int pending;
  final int failed;
  final int synced;
  final DateTime? lastSyncedAt;
  final String? lastError;

  int get outstanding => pending + failed;
}
