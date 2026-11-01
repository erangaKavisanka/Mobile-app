import 'app_preferences.dart';

abstract class SettingsRepository {
  Stream<AppPreferences> watchPreferences();
  Future<AppPreferences> load();
  Future<void> save(AppPreferences preferences);
}

abstract class UserRepository {
  Stream<UserProfile?> watchLocalUser();

  /// Returns the local profile, creating one with a generated node id on first run.
  Future<UserProfile> ensureLocalUser();
  Future<void> updateDisplayName(String name);
}

/// Wipes every locally stored record.
abstract class LocalDataManager {
  Future<void> clearAll();
}
