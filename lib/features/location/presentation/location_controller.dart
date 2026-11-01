import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/location_fix.dart';

class LocationState {
  const LocationState({
    this.permission = LocationPermissionState.unknown,
    this.fix,
    this.error,
    this.isLoading = false,
  });

  final LocationPermissionState permission;

  /// Most recent fix obtained in this session.
  final LocationFix? fix;
  final String? error;
  final bool isLoading;

  LocationState copyWith({
    LocationPermissionState? permission,
    LocationFix? fix,
    String? error,
    bool clearError = false,
    bool? isLoading,
  }) {
    return LocationState(
      permission: permission ?? this.permission,
      fix: fix ?? this.fix,
      error: clearError ? null : error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationController extends Notifier<LocationState> {
  @override
  LocationState build() {
    Future.microtask(_checkPermission);
    return const LocationState();
  }

  Future<void> _checkPermission() async {
    final permission = await ref.read(locationSourceProvider).permissionState();
    state = state.copyWith(permission: permission);
    if (permission == LocationPermissionState.granted && state.fix == null) {
      await refresh();
    }
  }

  Future<void> requestPermission() async {
    final permission = await ref
        .read(locationSourceProvider)
        .requestPermission();
    state = state.copyWith(permission: permission);
    if (permission == LocationPermissionState.granted) await refresh();
  }

  Future<void> openSettings() =>
      ref.read(locationSourceProvider).openAppSettings();

  /// Reads the GPS. Stores the fix in history only if the privacy setting allows.
  Future<LocationFix?> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final fix = await ref.read(locationSourceProvider).currentFix();
      state = state.copyWith(
        fix: fix,
        isLoading: false,
        permission: LocationPermissionState.granted,
      );
      final prefs = ref.read(preferencesProvider).value;
      if (prefs?.saveLocationHistory ?? true) {
        await ref.read(locationRepositoryProvider).record(fix);
      }
      return fix;
    } on LocationUnavailableException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    }
  }

  /// Location for an SOS: a fresh fix if possible, else a recent one, else
  /// null. Returns null without touching GPS when the user turned the
  /// "attach location to SOS" privacy setting off.
  Future<LocationFix?> captureForSos({
    Duration maxAge = const Duration(minutes: 10),
  }) async {
    final prefs = ref.read(preferencesProvider).value;
    if (prefs != null && !prefs.attachLocationToSos) return null;
    final permission = await ref.read(locationSourceProvider).permissionState();
    if (permission != LocationPermissionState.granted) return null;
    final fresh = await refresh().timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
    if (fresh != null) return fresh;
    final last = state.fix;
    if (last != null && DateTime.now().difference(last.recordedAt) < maxAge) {
      return last;
    }
    return null;
  }
}

final locationControllerProvider =
    NotifierProvider<LocationController, LocationState>(LocationController.new);
