import 'package:flutter_test/flutter_test.dart';
import 'package:parent_app/features/children/models/child_model.dart';
import 'package:parent_app/features/tracking/models/trip_details.dart';
import 'package:parent_app/features/tracking/services/trip_id_for_child.dart';

void main() {
  Map<String, dynamic> tripResponse({
    double destinationLatitude = 6.9,
    double destinationLongitude = 79.8,
  }) {
    return {
      'tripId': 'route_08',
      'routeId': 'route_08',
      'routeName': 'Route 08',
      'active': false,
      'destination': {
        'name': 'School',
        'latitude': destinationLatitude,
        'longitude': destinationLongitude,
      },
      'stops': [
        {
          'id': 'stop_1',
          'name': 'Pickup',
          'latitude': 6.8,
          'longitude': 79.7,
          'order': 1,
        },
      ],
    };
  }

  test('parses a backend trip without inventing an active state', () {
    final trip = TripDetails.fromMap(tripResponse());

    expect(trip.tripId, 'route_08');
    expect(trip.active, isFalse);
    expect(trip.destination.name, 'School');
    expect(trip.stops, hasLength(1));
    expect(trip.driver, isNull);
    expect(trip.vehicle, isNull);
  });

  test('rejects invalid destination coordinates', () {
    expect(
      () => TripDetails.fromMap(tripResponse(destinationLatitude: 91)),
      throwsFormatException,
    );
  });

  test('preserves when an ETA is an approximation', () {
    final eta = EtaInfo.fromMap({
      'etaSeconds': 300,
      'etaMinutes': 5,
      'distanceMeters': 1200,
      'distanceKm': '1.2',
      'calculatedAt': '2025-01-01T10:00:00.000Z',
      'isEstimate': true,
    });

    expect(eta.isEstimate, isTrue);
    expect(eta.etaMinutes, 5);
  });

  test('maps only configured route numbers to trip identifiers', () {
    ChildModel childForRoute(String route) =>
        ChildModel.fromMap({'route': route}, 'child_1');

    expect(tripIdForChild(childForRoute('Route 08')), 'route_08');
    expect(tripIdForChild(childForRoute('Route 14')), 'route_14');
    expect(tripIdForChild(childForRoute('Route 12')), 'trip_001');
    expect(tripIdForChild(childForRoute('Route 120')), isNull);
    expect(tripIdForChild(null), isNull);
  });

  test('uses the assigned trip ID before route fallbacks', () {
    final child = ChildModel.fromMap({
      'route': 'Route 08',
      'routeId': 'route_08',
      'tripId': 'trip_001',
    }, 'child_1');

    expect(tripIdForChild(child), 'trip_001');
  });

  test('maps a route ID to its configured trip ID without equating them', () {
    final child = ChildModel.fromMap(
      {'routeId': 'route_colombo_01'},
      'child_1',
    );

    expect(tripIdForChild(child), 'trip_001');
  });

  test('leaves unknown route IDs unconfigured', () {
    final child = ChildModel.fromMap(
      {'routeId': 'route_unconfigured'},
      'child_1',
    );

    expect(tripIdForChild(child), isNull);
  });

  test('does not write an empty route into Firestore maps', () {
    final child = ChildModel.fromMap({'name': 'Student'}, 'child_1');

    expect(child.toMap().containsKey('route'), isFalse);
  });
}
