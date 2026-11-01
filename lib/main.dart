import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/database/app_database.dart';
import 'data/repositories/settings_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase(
    driftDatabase(
      name: 'ecolink',
      // Only used when running in a browser; see web/ for the two assets.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  final user = await UserRepositoryImpl(db).ensureLocalUser();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localNodeIdProvider.overrideWithValue(user.nodeId),
      ],
      child: const EcoLinkApp(),
    ),
  );
}
