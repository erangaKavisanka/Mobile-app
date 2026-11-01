import 'package:drift/drift.dart';

import '../../features/devices/domain/node.dart';
import '../../features/messaging/domain/message.dart';
import '../../features/sos/domain/sos_event.dart';
import '../../features/synchronization/domain/sync_item.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Nodes,
    Conversations,
    Messages,
    SosEvents,
    LocationRecords,
    SyncQueue,
    DeviceLogs,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump when a table changes and add a step to [_upgrade].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) => _upgrade(m, from, to),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _upgrade(Migrator m, int from, int to) async {
    // Schema v1 is the first release; there is nothing to migrate yet.
    // Add `if (from < 2) { await m.addColumn(...); }` blocks here as the
    // schema evolves, one block per version.
    if (from > to) {
      throw StateError('Cannot downgrade database from v$from to v$to.');
    }
  }

  /// Deletes every row from every table (children before parents). The local
  /// user row is kept so the phone retains its node identity on the mesh.
  Future<void> clearAllData() => transaction(() async {
    for (final table in <TableInfo>[
      deviceLogs,
      messages,
      conversations,
      sosEvents,
      locationRecords,
      syncQueue,
      nodes,
      appSettings,
    ]) {
      await delete(table).go();
    }
    await (delete(users)..where((t) => t.isLocal.equals(false))).go();
  });
}
