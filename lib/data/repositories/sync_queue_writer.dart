import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../features/synchronization/domain/sync_item.dart';
import '../database/app_database.dart';

extension SyncQueueWriter on AppDatabase {
  /// Adds an entity to the cloud sync queue. Call inside the same transaction
  /// that writes the entity so both succeed or fail together.
  ///
  /// The (entity, id, operation) triple is unique: a repeated `create` is
  /// ignored, and a repeated `update` replaces the queued snapshot and resets
  /// retry tracking.
  Future<void> enqueueSync(
    SyncEntityType type,
    String entityId,
    SyncOperation operation,
    String payload, {
    DateTime? now,
  }) async {
    final existing =
        await (select(syncQueue)..where(
              (t) =>
                  t.entityType.equalsValue(type) &
                  t.entityId.equals(entityId) &
                  t.operation.equalsValue(operation),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: const IdGenerator().next(),
          entityType: type,
          entityId: entityId,
          operation: operation,
          payload: payload,
          status: SyncStatus.pending,
          createdAt: now ?? DateTime.now(),
        ),
      );
    } else if (operation == SyncOperation.update) {
      await (update(syncQueue)..where((t) => t.id.equals(existing.id))).write(
        SyncQueueCompanion(
          payload: Value(payload),
          status: const Value(SyncStatus.pending),
          retryCount: const Value(0),
          lastError: const Value(null),
          syncedAt: const Value(null),
        ),
      );
    }
  }
}
