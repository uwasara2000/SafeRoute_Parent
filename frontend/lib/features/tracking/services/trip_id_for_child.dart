import '../../children/models/child_model.dart';

// These are the route-to-trip relationships in backend/src/services/tripService.js.
// Route identifiers are not necessarily trip identifiers (route_colombo_01 is
// served by trip_001), so keep this mapping explicit.
const Map<String, String> _tripIdsByRouteId = {
  'route_colombo_01': 'trip_001',
  'route_08': 'route_08',
  'route_14': 'route_14',
};

String? tripIdForChild(ChildModel? child) {
  if (child == null) return null;

  final assignedTripId = child.tripId?.trim();
  if (assignedTripId != null && assignedTripId.isNotEmpty) {
    return assignedTripId;
  }

  final assignedRouteId = child.routeId?.trim();
  if (assignedRouteId != null && assignedRouteId.isNotEmpty) {
    final tripId = _tripIdsByRouteId[assignedRouteId];
    if (tripId != null) return tripId;
  }

  final routeNumber = RegExp(r'\d+').firstMatch(child.route)?.group(0);
  return switch (routeNumber) {
    '8' || '08' => 'route_08',
    '14' => 'route_14',
    '12' => 'trip_001',
    _ => null,
  };
}
