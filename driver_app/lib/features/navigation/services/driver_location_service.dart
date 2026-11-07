import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_location.dart';

class DriverLocationService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _simulationTimer;
  int _waypointIndex = 0;
  bool _isBroadcasting = false;

  bool get isBroadcasting => _isBroadcasting;

  // Realistic Route 08 Waypoints (Nawala -> Nugegoda -> Havelock -> Royal College)
  static const List<Map<String, double>> route08Waypoints = [
    {'lat': 6.8906, 'lng': 79.8890, 'heading': 180.0, 'speed': 7.5}, // Nawala Junction
    {'lat': 6.8860, 'lng': 79.8885, 'heading': 190.0, 'speed': 8.2}, // Open University Stop
    {'lat': 6.8812, 'lng': 79.8880, 'heading': 185.0, 'speed': 9.0}, // Nugegoda Flyover approach
    {'lat': 6.8745, 'lng': 79.8920, 'heading': 260.0, 'speed': 6.5}, // Pagoda Road Stop
    {'lat': 6.8722, 'lng': 79.8850, 'heading': 300.0, 'speed': 8.8}, // High Level Road Kirulapone
    {'lat': 6.8770, 'lng': 79.8780, 'heading': 330.0, 'speed': 9.5}, // Havelock Road
    {'lat': 6.8850, 'lng': 79.8710, 'heading': 345.0, 'speed': 8.5}, // Thimbirigasyaya
    {'lat': 6.8950, 'lng': 79.8660, 'heading': 350.0, 'speed': 7.8}, // Reid Avenue / Colombo 07
    {'lat': 6.9030, 'lng': 79.8615, 'heading': 355.0, 'speed': 5.0}, // Royal College Gate
  ];

  /// Broadcast live location to Realtime Database
  Future<void> broadcastLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speedMps,
  }) async {
    final location = BusLocation(
      latitude: latitude,
      longitude: longitude,
      heading: heading,
      speedMps: speedMps,
      accuracyM: 5.0,
      updatedAt: DateTime.now(),
    );

    try {
      // 1. Update Firebase Realtime Database (listened to by parent app)
      await _database.ref('liveTrips/$tripId/location').set(location.toMap());
      await _database.ref('liveTrips/$tripId/active').set(true);

      // 2. Also mirror to Firestore for historical journey & admin monitoring
      await _firestore.collection('trips').doc(tripId).set({
        'currentLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'heading': heading ?? 0.0,
          'speed': speedMps ?? 0.0,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'status': 'in_progress',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Retain offline tolerance
    }
  }

  /// Start simulated vehicle movement along Route 08
  void startLocationBroadcast({
    required String tripId,
    Function(BusLocation)? onLocationUpdated,
  }) {
    if (_isBroadcasting) return;
    _isBroadcasting = true;

    _database.ref('liveTrips/$tripId/active').set(true);

    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isBroadcasting) return;

      final current = route08Waypoints[_waypointIndex];
      final location = BusLocation(
        latitude: current['lat']!,
        longitude: current['lng']!,
        heading: current['heading'],
        speedMps: current['speed'],
        accuracyM: 4.5,
        updatedAt: DateTime.now(),
      );

      broadcastLocation(
        tripId: tripId,
        latitude: location.latitude,
        longitude: location.longitude,
        heading: location.heading,
        speedMps: location.speedMps,
      );

      onLocationUpdated?.call(location);

      _waypointIndex = (_waypointIndex + 1) % route08Waypoints.length;
    });
  }

  /// Stop broadcasting when trip ends
  Future<void> stopLocationBroadcast(String tripId) async {
    _isBroadcasting = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _waypointIndex = 0;

    try {
      await _database.ref('liveTrips/$tripId/active').set(false);
      await _firestore.collection('trips').doc(tripId).set({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void dispose() {
    _simulationTimer?.cancel();
  }
}

