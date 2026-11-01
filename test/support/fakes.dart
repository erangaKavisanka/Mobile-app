import 'dart:async';

import 'package:ecolink/core/errors/app_exception.dart';
import 'package:ecolink/features/location/domain/location_fix.dart';
import 'package:ecolink/features/location/domain/location_repository.dart';

class FakeLocationSource implements LocationSource {
  FakeLocationSource({
    this.permission = LocationPermissionState.granted,
    this.fix,
  });

  LocationPermissionState permission;
  LocationFix? fix;
  int requests = 0;

  @override
  Future<LocationPermissionState> permissionState() async => permission;

  @override
  Future<LocationPermissionState> requestPermission() async {
    requests++;
    return permission;
  }

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<LocationFix> currentFix() async {
    if (permission != LocationPermissionState.granted) {
      throw const LocationUnavailableException('Location permission denied.');
    }
    final f = fix;
    if (f == null) throw const LocationUnavailableException('No GPS fix.');
    return f;
  }

  @override
  Stream<LocationFix> fixes() => const Stream.empty();
}
