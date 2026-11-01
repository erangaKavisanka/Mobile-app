import 'dart:async';

import '../../core/errors/app_exception.dart';
import '../../features/synchronization/domain/sync_item.dart';
import '../../features/synchronization/domain/sync_repository.dart';

class SyncResult {
  const SyncResult({this.synced = 0, this.failed = 0});
  final int synced;
  final int failed;
}

/// Uploads queued items through a [CloudGateway].
///
/// Items are attempted in queue order. Failures are recorded with a retry
/// count and wait out an exponential backoff before the next automatic
/// attempt. If an item fails, later items of the same entity are skipped in
/// this run, so the remote side never sees an update without its create.
class SyncService {
  SyncService({required SyncRepository queue, required CloudGateway cloud})
    : _queue = queue,
      _cloud = cloud;

  final SyncRepository _queue;
  final CloudGateway _cloud;
  bool _running = false;

  bool get isSimulated => _cloud.isSimulated;

  /// Returns uploads interrupted by an app restart to the queue.
  Future<void> recoverInterrupted() => _queue.resetInterrupted();

  /// Uploads everything that is due. [force] also retries failed items that
  /// are still inside their backoff window (a manual "Sync now").
  Future<SyncResult> syncNow({bool force = false}) async {
    if (_running) return const SyncResult();
    _running = true;
    var synced = 0, failed = 0;
    final failedEntities = <String>{};
    try {
      for (final item in await _queue.due(ignoreBackoff: force)) {
        if (failedEntities.contains(item.entityKey)) continue;
        await _queue.markInProgress(item.id);
        try {
          await _cloud.push(item);
          // False when the entity was re-queued while uploading; the newer
          // snapshot stays pending and goes out on the next run.
          if (await _queue.markSynced(item.id, expectedPayload: item.payload)) {
            synced++;
          }
        } on SyncException catch (e) {
          await _queue.markFailed(item.id, e.message);
          failedEntities.add(item.entityKey);
          failed++;
        } catch (e) {
          await _queue.markFailed(item.id, 'Unexpected error: $e');
          failedEntities.add(item.entityKey);
          failed++;
        }
      }
    } finally {
      _running = false;
    }
    return SyncResult(synced: synced, failed: failed);
  }

  /// Puts every failed item back in the queue immediately and uploads.
  Future<SyncResult> retryFailed() async {
    await _queue.retryFailed();
    return syncNow(force: true);
  }
}

/// Stand-in for the AWS IoT Core uploader. It succeeds only while the
/// (simulated) Internet toggle is on; no data leaves the phone.
class SimulatedCloudGateway implements CloudGateway {
  SimulatedCloudGateway({
    required bool Function() isInternetAvailable,
    this.latency = const Duration(milliseconds: 150),
  }) : _isInternetAvailable = isInternetAvailable;

  final bool Function() _isInternetAvailable;
  final Duration latency;
  final Map<String, String> _received = {};

  /// Payloads the simulated cloud holds, keyed by idempotency key. A retried
  /// item overwrites its entry instead of adding a second one.
  Map<String, String> get received => Map.unmodifiable(_received);

  @override
  bool get isSimulated => true;

  @override
  Future<void> push(SyncItem item) async {
    await Future<void>.delayed(latency);
    if (!_isInternetAvailable()) {
      throw const SyncException('No Internet connection (simulated)');
    }
    _received[item.idempotencyKey] = item.payload;
  }
}
