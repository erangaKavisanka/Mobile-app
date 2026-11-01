import 'sync_item.dart';

abstract class SyncRepository {
  Stream<List<SyncItem>> watchItems({int limit = 100});
  Stream<SyncSummary> watchSummary();

  /// Items to upload now, oldest first. `failed` items wait out their retry
  /// backoff unless [ignoreBackoff] is set (a manual "sync now"). An item is
  /// withheld while an earlier item of the same entity is unsynced and not
  /// itself due, so an update is never uploaded before its create.
  Future<List<SyncItem>> due({int limit = 50, bool ignoreBackoff = false});
  Future<void> markInProgress(String id);

  /// Completes an upload. Applies only if the row is still `inProgress` with
  /// [expectedPayload]; if the entity changed meanwhile (re-queued with a new
  /// snapshot) the row stays pending so the newer snapshot is uploaded too.
  /// Returns whether the row was marked synced.
  Future<bool> markSynced(String id, {String? expectedPayload, DateTime? at});

  /// Records a failed attempt (increments `retryCount`). Applies only to a row
  /// that is still `inProgress`.
  Future<void> markFailed(String id, String error, {DateTime? at});
  Future<void> retryFailed();

  /// Returns items left `inProgress` by an interrupted run to `pending`.
  Future<void> resetInterrupted();
}

/// Cloud endpoint abstraction. A real implementation will publish to AWS IoT
/// Core; until then [SimulatedCloudGateway] stands in.
abstract class CloudGateway {
  bool get isSimulated;

  /// Resolves on confirmed receipt; throws SyncException otherwise.
  ///
  /// Must be idempotent per [SyncItem.idempotencyKey]: the caller may send the
  /// same item again after a timeout or lost response.
  Future<void> push(SyncItem item);
}
