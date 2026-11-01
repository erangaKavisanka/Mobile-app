class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
    this.altitude,
    this.id,
  });

  final String? id;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime recordedAt;
}

enum LocationPermissionState {
  unknown,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}
