import 'package:firebase_database/firebase_database.dart';

import '../models/bus_location.dart';

class BusTrackingService {
  final FirebaseDatabase _database;

  BusTrackingService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Listen to real-time location stream for a given trip
  Stream<BusLocation?> watchLocation(String tripId) {
    final ref = _database.ref('liveTrips/$tripId/location');

    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      if (value is! Map) {
        throw const FormatException('Live bus location is not an object.');
      }

      final location = BusLocation.fromMap(value);
      if (!location.isValid) {
        throw const FormatException(
          'Live bus location has invalid coordinates.',
        );
      }
      return location;
    });
  }

  /// Listen to trip active status
  Stream<bool?> watchTripStatus(String tripId) {
    final ref = _database.ref('liveTrips/$tripId/active');
    return ref.onValue.map((event) {
      final val = event.snapshot.value;
      return val is bool ? val : null;
    });
  }
}
