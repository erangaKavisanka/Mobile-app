import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../core/utils/id_generator.dart';
import '../../features/settings/domain/app_preferences.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../database/app_database.dart';

/// Preferences stored as key/value rows in `app_settings`.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _theme = 'theme_mode';
  static const _notifications = 'notifications_enabled';
  static const _notifySos = 'notify_sos';
  static const _notifyMessages = 'notify_messages';
  static const _autoConnect = 'auto_connect_device';
  static const _saveLocation = 'save_location_history';
  static const _attachLocation = 'attach_location_to_sos';
  static const _simulateInternet = 'simulate_internet';

  AppPreferences _fromRows(List<AppSettingRow> rows) {
    final map = {for (final r in rows) r.key: r.value};
    bool flag(String key, bool fallback) =>
        map[key] == null ? fallback : map[key] == 'true';
    const d = AppPreferences();
    return AppPreferences(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == map[_theme],
        orElse: () => d.themeMode,
      ),
      notificationsEnabled: flag(_notifications, d.notificationsEnabled),
      notifyOnSos: flag(_notifySos, d.notifyOnSos),
      notifyOnMessages: flag(_notifyMessages, d.notifyOnMessages),
      autoConnectDevice: flag(_autoConnect, d.autoConnectDevice),
      saveLocationHistory: flag(_saveLocation, d.saveLocationHistory),
      attachLocationToSos: flag(_attachLocation, d.attachLocationToSos),
      simulateInternet: flag(_simulateInternet, d.simulateInternet),
    );
  }

  @override
  Stream<AppPreferences> watchPreferences() =>
      _db.select(_db.appSettings).watch().map(_fromRows);

  @override
  Future<AppPreferences> load() async =>
      _fromRows(await _db.select(_db.appSettings).get());

  @override
  Future<void> save(AppPreferences p) async {
    final values = {
      _theme: p.themeMode.name,
      _notifications: '${p.notificationsEnabled}',
      _notifySos: '${p.notifyOnSos}',
      _notifyMessages: '${p.notifyOnMessages}',
      _autoConnect: '${p.autoConnectDevice}',
      _saveLocation: '${p.saveLocationHistory}',
      _attachLocation: '${p.attachLocationToSos}',
      _simulateInternet: '${p.simulateInternet}',
    };
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.appSettings,
        values.entries
            .map((e) => AppSettingsCompanion.insert(key: e.key, value: e.value))
            .toList(),
      );
    });
  }
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _ids = IdGenerator();

  UserProfile _toProfile(UserRow r) => UserProfile(
    id: r.id,
    displayName: r.displayName,
    nodeId: r.nodeId,
    createdAt: r.createdAt,
  );

  @override
  Stream<UserProfile?> watchLocalUser() {
    final q = _db.select(_db.users)..where((t) => t.isLocal.equals(true));
    return q.watchSingleOrNull().map((r) => r == null ? null : _toProfile(r));
  }

  @override
  Future<UserProfile> ensureLocalUser() {
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.users,
      )..where((t) => t.isLocal.equals(true))).getSingleOrNull();
      if (existing != null) return _toProfile(existing);
      final id = _ids.next();
      final nodeId = 'ECO-${id.substring(0, 6).toUpperCase()}';
      final row = await _db
          .into(_db.users)
          .insertReturning(
            UsersCompanion.insert(
              id: id,
              displayName: 'Traveller',
              nodeId: nodeId,
              createdAt: _clock(),
            ),
          );
      return _toProfile(row);
    });
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await (_db.update(_db.users)..where((t) => t.isLocal.equals(true))).write(
      UsersCompanion(displayName: Value(trimmed)),
    );
  }
}

class LocalDataManagerImpl implements LocalDataManager {
  LocalDataManagerImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> clearAll() => _db.clearAllData();
}
