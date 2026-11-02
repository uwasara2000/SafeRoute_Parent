class DriverInfo {
  final String driverId;
  final String name;
  final String phone;
  final String licenseNo;

  const DriverInfo({
    required this.driverId,
    required this.name,
    required this.phone,
    required this.licenseNo,
  });

  factory DriverInfo.fromMap(Map<String, dynamic> map) {
    return DriverInfo(
      driverId: map['driverId'] ?? '',
      name: map['name'] ?? 'Assigned Driver',
      phone: map['phone'] ?? '',
      licenseNo: map['licenseNo'] ?? '',
    );
  }
}

class VehicleInfo {
  final String vehicleId;
  final String plateNumber;
  final String model;
  final int capacity;

  const VehicleInfo({
    required this.vehicleId,
    required this.plateNumber,
    required this.model,
    required this.capacity,
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      vehicleId: map['vehicleId'] ?? '',
      plateNumber: map['plateNumber'] ?? 'Bus',
      model: map['model'] ?? 'School Bus',
      capacity: (map['capacity'] as num?)?.toInt() ?? 30,
    );
  }
}

class BusStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int order;

  const BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory BusStop.fromMap(Map<String, dynamic> map) {
    return BusStop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class TripDetails {
  final String tripId;
  final String routeId;
  final String routeName;
  final bool active;
  final DriverInfo driver;
  final VehicleInfo vehicle;
  final BusStop destination;
  final List<BusStop> stops;

  const TripDetails({
    required this.tripId,
    required this.routeId,
    required this.routeName,
    required this.active,
    required this.driver,
    required this.vehicle,
    required this.destination,
    required this.stops,
  });

  factory TripDetails.fromMap(Map<String, dynamic> map) {
    final stopsList = (map['stops'] as List<dynamic>?)
            ?.map((s) => BusStop.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [];

    final destMap = map['destination'] as Map<String, dynamic>? ?? {};

    return TripDetails(
      tripId: map['tripId'] ?? '',
      routeId: map['routeId'] ?? '',
      routeName: map['routeName'] ?? '',
      active: map['active'] ?? true,
      driver: DriverInfo.fromMap(map['driver'] as Map<String, dynamic>? ?? {}),
      vehicle: VehicleInfo.fromMap(map['vehicle'] as Map<String, dynamic>? ?? {}),
      destination: BusStop(
        id: 'destination',
        name: destMap['name'] ?? 'School',
        latitude: (destMap['latitude'] as num?)?.toDouble() ?? 6.9080,
        longitude: (destMap['longitude'] as num?)?.toDouble() ?? 79.8970,
        order: 99,
      ),
      stops: stopsList,
    );
  }
}

class EtaInfo {
  final int etaSeconds;
  final int etaMinutes;
  final int distanceMeters;
  final String distanceKm;
  final String? polyline;
  final DateTime calculatedAt;

  const EtaInfo({
    required this.etaSeconds,
    required this.etaMinutes,
    required this.distanceMeters,
    required this.distanceKm,
    this.polyline,
    required this.calculatedAt,
  });

  factory EtaInfo.fromMap(Map<String, dynamic> map) {
    return EtaInfo(
      etaSeconds: (map['etaSeconds'] as num?)?.toInt() ?? 0,
      etaMinutes: (map['etaMinutes'] as num?)?.toInt() ?? 1,
      distanceMeters: (map['distanceMeters'] as num?)?.toInt() ?? 0,
      distanceKm: map['distanceKm']?.toString() ?? '0.0',
      polyline: map['polyline'] as String?,
      calculatedAt: map['calculatedAt'] != null
          ? DateTime.tryParse(map['calculatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

