import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../core/errors/app_exception.dart';
import '../../features/location/domain/location_fix.dart';
import '../../features/location/domain/location_repository.dart';

class GeolocatorLocationSource implements LocationSource {
  const GeolocatorLocationSource();

  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 15),
  );

  LocationFix _fix(Position p) => LocationFix(
    latitude: p.latitude,
    longitude: p.longitude,
    accuracy: p.accuracy,
    altitude: p.altitude,
    recordedAt: p.timestamp,
  );

  LocationPermissionState _map(LocationPermission p) => switch (p) {
    LocationPermission.always ||
    LocationPermission.whileInUse => LocationPermissionState.granted,
    LocationPermission.denied => LocationPermissionState.denied,
    LocationPermission.deniedForever => LocationPermissionState.deniedForever,
    LocationPermission.unableToDetermine => LocationPermissionState.unknown,
  };

  @override
  Future<LocationPermissionState> permissionState() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionState.serviceDisabled;
    }
    return _map(await Geolocator.checkPermission());
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionState.serviceDisabled;
    }
    return _map(await Geolocator.requestPermission());
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Future<LocationFix> currentFix() async {
    try {
      return _fix(
        await Geolocator.getCurrentPosition(locationSettings: _settings),
      );
    } on TimeoutException {
      throw const LocationUnavailableException(
        'Timed out waiting for a GPS fix.',
      );
    } on PermissionDeniedException {
      throw const LocationUnavailableException('Location permission denied.');
    } on LocationServiceDisabledException {
      throw const LocationUnavailableException(
        'Location services are turned off.',
      );
    } catch (e) {
      throw LocationUnavailableException('Could not read location: $e');
    }
  }

  @override
  Stream<LocationFix> fixes() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
    ),
  ).map(_fix);
}
