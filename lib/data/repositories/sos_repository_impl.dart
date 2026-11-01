import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/sos/domain/sos_event.dart';
import '../../features/sos/domain/sos_repository.dart';
import '../../features/synchronization/domain/sync_item.dart';
import '../database/app_database.dart';
import 'sync_queue_writer.dart';

class SosRepositoryImpl implements SosRepository {
  SosRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Forward order of the lifecycle. `failed` sits between `triggered` and
  /// `sentToGateway`: a retry moves forward from it, and a late ACK for a
  /// failed event (explicit proof it got through) also moves forward.
  static const _order = {
    SosStatus.triggered: 0,
    SosStatus.failed: 1,
    SosStatus.sentToGateway: 2,
    SosStatus.acknowledged: 3,
    SosStatus.propagated: 4,
    SosStatus.resolved: 5,
    SosStatus.cancelled: 5,
  };

  SosEvent _toEvent(SosEventRow r) => SosEvent(
    id: r.id,
    sourceNodeId: r.sourceNodeId,
    status: r.status,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    latitude: r.latitude,
    longitude: r.longitude,
    accuracy: r.accuracy,
    note: r.note,
    sentAt: r.sentAt,
    acknowledgedAt: r.acknowledgedAt,
    propagatedAt: r.propagatedAt,
    closedAt: r.closedAt,
    nodesReached: r.nodesReached,
    isSimulated: r.isSimulated,
  );

  String _payload(SosEvent e) => jsonEncode({
    'id': e.id,
    'source': e.sourceNodeId,
    'status': e.status.name,
    'created_at': e.createdAt.toUtc().toIso8601String(),
    if (e.hasLocation)
      'location': {
        'lat': e.latitude,
        'lon': e.longitude,
        'accuracy': e.accuracy,
      },
    if (e.note != null) 'note': e.note,
    'simulated': e.isSimulated,
  });

  @override
  Stream<List<SosEvent>> watchAll() {
    final q = _db.select(_db.sosEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_toEvent).toList());
  }

  @override
  Stream<List<SosEvent>> watchActive() =>
      watchAll().map((events) => events.where((e) => e.isActive).toList());

  @override
  Stream<SosEvent?> watch(String id) {
    final q = _db.select(_db.sosEvents)..where((t) => t.id.equals(id));
    return q.watchSingleOrNull().map((r) => r == null ? null : _toEvent(r));
  }

  @override
  Future<SosEvent?> get(String id) async {
    final row = await (_db.select(
      _db.sosEvents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEvent(row);
  }

  @override
  Future<List<SosEvent>> active() async {
    final rows =
        await (_db.select(_db.sosEvents)
              ..where(
                (t) => t.status.isNotInValues([
                  SosStatus.resolved,
                  SosStatus.cancelled,
                ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_toEvent).toList();
  }

  @override
  Future<bool> create(SosEvent e) {
    return _db.transaction(() async {
      final inserted = await _db
          .into(_db.sosEvents)
          .insertReturningOrNull(
            SosEventsCompanion.insert(
              id: e.id,
              sourceNodeId: e.sourceNodeId,
              status: e.status,
              createdAt: e.createdAt,
              updatedAt: e.updatedAt,
              latitude: Value(e.latitude),
              longitude: Value(e.longitude),
              accuracy: Value(e.accuracy),
              note: Value(e.note),
              sentAt: Value(e.sentAt),
              acknowledgedAt: Value(e.acknowledgedAt),
              propagatedAt: Value(e.propagatedAt),
              nodesReached: Value(e.nodesReached),
              isSimulated: Value(e.isSimulated),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted == null) return false;
      await _db.enqueueSync(
        SyncEntityType.sosEvent,
        e.id,
        SyncOperation.create,
        _payload(e),
        now: e.createdAt,
      );
      return true;
    });
  }

  @override
  Future<void> advance(
    String id,
    SosStatus status, {
    int? nodesReached,
    bool simulated = false,
    DateTime? at,
  }) {
    return _db.transaction(() async {
      final current = await get(id);
      if (current == null) return;
      final closing =
          status == SosStatus.resolved || status == SosStatus.cancelled;
      if (!current.isActive) return; // closed events never change again
      // The only permitted backwards step: a transmission error for an SOS
      // that has not been acknowledged yet.
      final isTxFailure =
          status == SosStatus.failed &&
          (current.status == SosStatus.triggered ||
              current.status == SosStatus.sentToGateway);
      if (!closing &&
          !isTxFailure &&
          _order[status]! <= _order[current.status]!) {
        // Late or duplicate acknowledgement: only refresh the node count.
        if (nodesReached != null && nodesReached > current.nodesReached) {
          await (_db.update(_db.sosEvents)..where((t) => t.id.equals(id)))
              .write(SosEventsCompanion(nodesReached: Value(nodesReached)));
        }
        return;
      }
      final now = at ?? _clock();
      await (_db.update(_db.sosEvents)..where((t) => t.id.equals(id))).write(
        SosEventsCompanion(
          status: Value(status),
          updatedAt: Value(now),
          sentAt: status == SosStatus.sentToGateway
              ? Value(now)
              : const Value.absent(),
          acknowledgedAt: status == SosStatus.acknowledged
              ? Value(now)
              : const Value.absent(),
          propagatedAt: status == SosStatus.propagated
              ? Value(now)
              : const Value.absent(),
          closedAt: closing ? Value(now) : const Value.absent(),
          nodesReached: Value.absentIfNull(nodesReached),
          isSimulated: simulated ? const Value(true) : const Value.absent(),
        ),
      );
      final updated = (await get(id))!;
      await _db.enqueueSync(
        SyncEntityType.sosEvent,
        id,
        SyncOperation.update,
        _payload(updated),
        now: now,
      );
    });
  }
}
