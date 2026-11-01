import 'package:drift/drift.dart';

import '../../features/synchronization/domain/sync_item.dart';
import '../../features/synchronization/domain/sync_repository.dart';
import '../database/app_database.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  SyncItem _toItem(SyncQueueRow r) => SyncItem(
    id: r.id,
    entityType: r.entityType,
    entityId: r.entityId,
    operation: r.operation,
    payload: r.payload,
    status: r.status,
    retryCount: r.retryCount,
    lastError: r.lastError,
    createdAt: r.createdAt,
    lastAttemptAt: r.lastAttemptAt,
    syncedAt: r.syncedAt,
  );

  @override
  Stream<List<SyncItem>> watchItems({int limit = 100}) {
    final q = _db.select(_db.syncQueue)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    return q.watch().map((rows) => rows.map(_toItem).toList());
  }

  @override
  Stream<SyncSummary> watchSummary() {
    return _db.select(_db.syncQueue).watch().map((rows) {
      DateTime? lastSynced;
      String? lastError;
      DateTime? lastErrorAt;
      var pending = 0, failed = 0, synced = 0;
      for (final r in rows) {
        switch (r.status) {
          case SyncStatus.pending:
          case SyncStatus.inProgress:
            pending++;
          case SyncStatus.failed:
            failed++;
          case SyncStatus.synced:
            synced++;
        }
        final s = r.syncedAt;
        if (s != null && (lastSynced == null || s.isAfter(lastSynced))) {
          lastSynced = s;
        }
        final a = r.lastAttemptAt;
        if (r.status == SyncStatus.failed &&
            a != null &&
            (lastErrorAt == null || a.isAfter(lastErrorAt))) {
          lastErrorAt = a;
          lastError = r.lastError;
        }
      }
      return SyncSummary(
        pending: pending,
        failed: failed,
        synced: synced,
        lastSyncedAt: lastSynced,
        lastError: lastError,
      );
    });
  }

  @override
  Future<List<SyncItem>> due({
    int limit = 50,
    bool ignoreBackoff = false,
  }) async {
    final rows =
        await (_db.select(_db.syncQueue)
              ..where((t) => t.status.equalsValue(SyncStatus.synced).not())
              ..orderBy([
                (t) => OrderingTerm.asc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    final now = _clock();
    final blocked = <String>{};
    final result = <SyncItem>[];
    for (final item in rows.map(_toItem)) {
      final waiting =
          item.status == SyncStatus.inProgress ||
          (item.status == SyncStatus.failed &&
              !ignoreBackoff &&
              now.isBefore(item.nextAttemptAt ?? now));
      if (blocked.contains(item.entityKey) || waiting) {
        blocked.add(item.entityKey);
        continue;
      }
      result.add(item);
      if (result.length == limit) break;
    }
    return result;
  }

  Future<void> _write(String id, SyncQueueCompanion values) =>
      (_db.update(_db.syncQueue)..where((t) => t.id.equals(id))).write(values);

  @override
  Future<void> markInProgress(String id) => _write(
    id,
    SyncQueueCompanion(
      status: const Value(SyncStatus.inProgress),
      lastAttemptAt: Value(_clock()),
    ),
  );

  @override
  Future<bool> markSynced(
    String id, {
    String? expectedPayload,
    DateTime? at,
  }) async {
    final updated =
        await (_db.update(_db.syncQueue)..where((t) {
              var match =
                  t.id.equals(id) & t.status.equalsValue(SyncStatus.inProgress);
              if (expectedPayload != null) {
                match = match & t.payload.equals(expectedPayload);
              }
              return match;
            }))
            .write(
              SyncQueueCompanion(
                status: const Value(SyncStatus.synced),
                syncedAt: Value(at ?? _clock()),
                lastError: const Value(null),
              ),
            );
    return updated > 0;
  }

  @override
  Future<void> markFailed(String id, String error, {DateTime? at}) async {
    await _db.customUpdate(
      'UPDATE sync_queue SET status = ?, retry_count = retry_count + 1, '
      'last_error = ?, last_attempt_at = ? WHERE id = ? AND status = ?',
      variables: [
        Variable.withString(SyncStatus.failed.name),
        Variable.withString(error),
        Variable.withDateTime(at ?? _clock()),
        Variable.withString(id),
        Variable.withString(SyncStatus.inProgress.name),
      ],
      updates: {_db.syncQueue},
    );
  }

  @override
  Future<void> retryFailed() async {
    await (_db.update(_db.syncQueue)
          ..where((t) => t.status.equalsValue(SyncStatus.failed)))
        .write(const SyncQueueCompanion(status: Value(SyncStatus.pending)));
  }

  @override
  Future<void> resetInterrupted() async {
    await (_db.update(_db.syncQueue)
          ..where((t) => t.status.equalsValue(SyncStatus.inProgress)))
        .write(const SyncQueueCompanion(status: Value(SyncStatus.pending)));
  }
}
