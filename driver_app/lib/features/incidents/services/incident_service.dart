import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Dispatch Delay Notification to Admin & Parents
  Future<void> reportDelay({
    required String tripId,
    required String routeName,
    required int delayMinutes,
    required String reason,
    String? note,
  }) async {
    try {
      // 1. Log to incidents / delays collection
      await _firestore.collection('delays').add({
        'tripId': tripId,
        'routeName': routeName,
        'delayMinutes': delayMinutes,
        'reason': reason,
        'note': note ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Update trip document
      await _firestore.collection('trips').doc(tripId).set({
        'status': 'delayed',
        'delayMinutes': delayMinutes,
        'delayReason': reason,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Create alert record visible in Admin Dashboard and Parent Alerts
      await _firestore.collection('alerts').add({
        'type': 'delay',
        'title': 'Trip Delay: $routeName (+$delayMinutes mins)',
        'description': '$reason${note != null && note.isNotEmpty ? ' - $note' : ''}',
        'tripId': tripId,
        'priority': 'medium',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Dispatch Emergency Alert (SOS)
  Future<void> reportEmergency({
    required String tripId,
    required String driverName,
    required String vehicleNumber,
    required String emergencyType,
    required double latitude,
    required double longitude,
    String? details,
  }) async {
    try {
      await _firestore.collection('emergencyAlerts').add({
        'tripId': tripId,
        'driverName': driverName,
        'vehicleNumber': vehicleNumber,
        'emergencyType': emergencyType,
        'details': details ?? '',
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Also create urgent platform alert for Admin
      await _firestore.collection('alerts').add({
        'type': 'emergency',
        'title': 'EMERGENCY: $vehicleNumber ($driverName)',
        'description': '$emergencyType: ${details ?? 'Immediate assistance requested'}',
        'priority': 'critical',
        'tripId': tripId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

