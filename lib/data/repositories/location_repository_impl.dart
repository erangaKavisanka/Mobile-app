import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../features/location/domain/location_fix.dart';
import '../../features/location/domain/location_repository.dart';
import '../database/app_database.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(this._db);

  final AppDatabase _db;
  static const _ids = IdGenerator();

  LocationFix _toFix(LocationRow r) => LocationFix(
    id: r.id,
    latitude: r.latitude,
    longitude: r.longitude,
    accuracy: r.accuracy,
    altitude: r.altitude,
    recordedAt: r.recordedAt,
  );

  @override
  Stream<LocationFix?> watchLatest() {
    final q = _db.select(_db.locationRecords)
      ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
      ..limit(1);
    return q.watch().map((rows) => rows.isEmpty ? null : _toFix(rows.first));
  }

  @override
  Stream<List<LocationFix>> watchHistory({int limit = 200}) {
    final q = _db.select(_db.locationRecords)
      ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
      ..limit(limit);
    return q.watch().map((rows) => rows.map(_toFix).toList());
  }

  @override
  Future<void> record(LocationFix fix) async {
    await _db
        .into(_db.locationRecords)
        .insert(
          LocationRecordsCompanion.insert(
            id: fix.id ?? _ids.next(),
            latitude: fix.latitude,
            longitude: fix.longitude,
            accuracy: Value(fix.accuracy),
            altitude: Value(fix.altitude),
            recordedAt: fix.recordedAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_db.locationRecords).go();
  }
}
