import 'package:flutter/material.dart';

class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.notifyOnSos = true,
    this.notifyOnMessages = true,
    this.autoConnectDevice = true,
    this.saveLocationHistory = true,
    this.attachLocationToSos = true,
    this.simulateInternet = false,
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool notifyOnSos;
  final bool notifyOnMessages;

  /// Connect to the gateway automatically on launch.
  final bool autoConnectDevice;

  /// Privacy: keep a local history of GPS fixes.
  final bool saveLocationHistory;

  /// Privacy: include coordinates when an SOS is triggered.
  final bool attachLocationToSos;

  /// Simulation: pretend Internet is available so the simulated cloud accepts
  /// uploads. No real network is involved.
  final bool simulateInternet;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? notifyOnSos,
    bool? notifyOnMessages,
    bool? autoConnectDevice,
    bool? saveLocationHistory,
    bool? attachLocationToSos,
    bool? simulateInternet,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyOnSos: notifyOnSos ?? this.notifyOnSos,
      notifyOnMessages: notifyOnMessages ?? this.notifyOnMessages,
      autoConnectDevice: autoConnectDevice ?? this.autoConnectDevice,
      saveLocationHistory: saveLocationHistory ?? this.saveLocationHistory,
      attachLocationToSos: attachLocationToSos ?? this.attachLocationToSos,
      simulateInternet: simulateInternet ?? this.simulateInternet,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.nodeId,
    required this.createdAt,
  });

  final String id;
  final String displayName;

  /// This phone's identity on the EcoLink network.
  final String nodeId;
  final DateTime createdAt;
}
