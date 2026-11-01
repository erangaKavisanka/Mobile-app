import 'location_fix.dart';

abstract class LocationRepository {
  Stream<LocationFix?> watchLatest();
  Stream<List<LocationFix>> watchHistory({int limit = 200});

  /// Stores a fix in the history. Callers decide whether the privacy setting
  /// allows this.
  Future<void> record(LocationFix fix);
  Future<void> clearHistory();
}

/// Platform access to the device GPS. Implemented with Geolocator; faked in tests.
abstract class LocationSource {
  Future<LocationPermissionState> permissionState();
  Future<LocationPermissionState> requestPermission();
  Future<void> openAppSettings();

  /// Throws LocationUnavailableException when no fix can be obtained.
  Future<LocationFix> currentFix();
  Stream<LocationFix> fixes();
}
