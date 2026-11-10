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
      driverId: map['driverId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      licenseNo: map['licenseNo']?.toString() ?? '',
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
      vehicleId: map['vehicleId']?.toString() ?? '',
      plateNumber: map['plateNumber']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
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
    final latitude = map['latitude'];
    final longitude = map['longitude'];
    final order = map['order'];
    if (latitude is! num ||
        !latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude is! num ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180 ||
        order is! num) {
      throw const FormatException('Trip stop contains invalid data.');
    }

    final name = map['name']?.toString().trim() ?? '';
    if (name.isEmpty) {
      throw const FormatException('Trip stop is missing a name.');
    }

    return BusStop(
      id: map['id']?.toString() ?? '',
      name: name,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      order: order.toInt(),
    );
  }
}

class TripDetails {
  final String tripId;
  final String routeId;
  final String routeName;
  final bool active;
  final DriverInfo? driver;
  final VehicleInfo? vehicle;
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
    String requiredText(String field) {
      final value = map[field];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Trip response is missing $field.');
      }
      return value;
    }

    final rawStops = map['stops'];
    if (rawStops is! List) {
      throw const FormatException('Trip response contains invalid stops.');
    }
    final stopsList = rawStops.map((stop) {
      if (stop is! Map) {
        throw const FormatException('Trip response contains an invalid stop.');
      }
      return BusStop.fromMap(Map<String, dynamic>.from(stop));
    }).toList();

    final rawDestination = map['destination'];
    if (rawDestination is! Map) {
      throw const FormatException('Trip response is missing its destination.');
    }
    final destMap = Map<String, dynamic>.from(rawDestination);
    destMap['id'] ??= 'destination';
    destMap['order'] ??= 99;
    final active = map['active'];
    if (active is! bool) {
      throw const FormatException('Trip response contains an invalid status.');
    }

    return TripDetails(
      tripId: requiredText('tripId'),
      routeId: requiredText('routeId'),
      routeName: requiredText('routeName'),
      active: active,
      driver: map['driver'] is Map
          ? DriverInfo.fromMap(Map<String, dynamic>.from(map['driver'] as Map))
          : null,
      vehicle: map['vehicle'] is Map
          ? VehicleInfo.fromMap(
              Map<String, dynamic>.from(map['vehicle'] as Map),
            )
          : null,
      destination: BusStop.fromMap(destMap),
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
  final bool isEstimate;

  const EtaInfo({
    required this.etaSeconds,
    required this.etaMinutes,
    required this.distanceMeters,
    required this.distanceKm,
    this.polyline,
    required this.calculatedAt,
    this.isEstimate = false,
  });

  factory EtaInfo.fromMap(Map<String, dynamic> map) {
    final etaSeconds = map['etaSeconds'];
    final etaMinutes = map['etaMinutes'];
    final distanceMeters = map['distanceMeters'];
    final distanceKm = map['distanceKm'];
    final calculatedAt = DateTime.tryParse(
      map['calculatedAt']?.toString() ?? '',
    );
    if (etaSeconds is! num ||
        etaMinutes is! num ||
        distanceMeters is! num ||
        (distanceKm is! String && distanceKm is! num) ||
        distanceKm.toString().trim().isEmpty ||
        calculatedAt == null) {
      throw const FormatException('ETA response contains invalid data.');
    }

    return EtaInfo(
      etaSeconds: etaSeconds.toInt(),
      etaMinutes: etaMinutes.toInt(),
      distanceMeters: distanceMeters.toInt(),
      distanceKm: distanceKm.toString(),
      polyline: map['polyline'] as String?,
      calculatedAt: calculatedAt,
      isEstimate: map['isEstimate'] == true,
    );
  }
}
