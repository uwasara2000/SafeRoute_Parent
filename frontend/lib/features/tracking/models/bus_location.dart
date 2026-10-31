class BusLocation {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speedMps;
  final double? accuracyM;
  final DateTime updatedAt;

  const BusLocation({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speedMps,
    this.accuracyM,
    required this.updatedAt,
  });

  factory BusLocation.fromMap(Map<dynamic, dynamic> map) {
    return BusLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      heading: (map['heading'] as num?)?.toDouble(),
      speedMps: (map['speedMps'] as num?)?.toDouble(),
      accuracyM: (map['accuracyM'] as num?)?.toDouble(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  bool get isValid =>
      latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
}

