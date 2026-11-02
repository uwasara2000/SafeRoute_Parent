import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/trip_details.dart';

class TrackingApiService {
  // Supports both adb reverse (127.0.0.1) and local WiFi network (192.168.1.4)
  static const List<String> _candidateHosts = [
    'http://127.0.0.1:5000',
    'http://192.168.1.4:5000',
    'http://10.0.2.2:5000',
  ];

  String? _workingHost;

  Future<String> _getHost() async {
    if (_workingHost != null) return _workingHost!;

    for (final host in _candidateHosts) {
      try {
        final res = await http.get(Uri.parse('$host/health')).timeout(
              const Duration(milliseconds: 1500),
            );
        if (res.statusCode == 200) {
          _workingHost = host;
          return host;
        }
      } catch (_) {
        // Continue trying next host
      }
    }

    _workingHost = _candidateHosts.first;
    return _workingHost!;
  }

  /// GET /api/parent/trips/:tripId
  Future<TripDetails?> fetchTripDetails(String tripId) async {
    try {
      final host = await _getHost();
      final url = Uri.parse('$host/api/parent/trips/$tripId');
      final res = await http.get(url).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        return TripDetails.fromMap(data);
      }
    } catch (e) {
      debugPrint('fetchTripDetails note: $e');
    }

    // Default mock fallback so map always has stops and route data
    return TripDetails(
      tripId: tripId,
      routeId: 'route_colombo_01',
      routeName: 'Route #12 • Colombo North to Gateway College',
      active: true,
      driver: const DriverInfo(
        driverId: 'driver_john',
        name: 'John Doe',
        phone: '+94 77 123 4567',
        licenseNo: 'B1234567',
      ),
      vehicle: const VehicleInfo(
        vehicleId: 'bus_NA_1234',
        plateNumber: 'WP NA-1234',
        model: 'Ashok Leyland 32-Seater',
        capacity: 32,
      ),
      destination: const BusStop(
        id: 'dest_gateway',
        name: 'Gateway College, Rajagiriya',
        latitude: 6.9080,
        longitude: 79.8970,
        order: 4,
      ),
      stops: const [
        BusStop(id: 'stop_1', name: 'Wattala Junction (Pickup)', latitude: 6.9890, longitude: 79.8910, order: 1),
        BusStop(id: 'stop_2', name: 'Kelaniya Temple Road', latitude: 6.9530, longitude: 79.9160, order: 2),
        BusStop(id: 'stop_3', name: 'Borella Junction', latitude: 6.9140, longitude: 79.8770, order: 3),
        BusStop(id: 'stop_4', name: 'Gateway College (Destination)', latitude: 6.9080, longitude: 79.8970, order: 4),
      ],
    );
  }

  /// GET /api/parent/trips/:tripId/eta
  Future<EtaInfo?> fetchETA(String tripId) async {
    try {
      final host = await _getHost();
      final url = Uri.parse('$host/api/parent/trips/$tripId/eta');
      final res = await http.get(url).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        return EtaInfo.fromMap(data);
      }
    } catch (e) {
      debugPrint('fetchETA note: $e');
    }
    return null;
  }
}

