import 'route_stop.dart';

class TripModel {
  final String id;
  final String routeName;
  final String busNumber;
  final String driverName;
  final String shift; // Morning or Afternoon
  final String destinationSchool;
  String status; // scheduled, in_progress, completed, delayed
  int currentStopIndex;
  int delayMinutes;
  final List<RouteStop> stops;
  DateTime? startedAt;
  DateTime? completedAt;

  TripModel({
    required this.id,
    required this.routeName,
    required this.busNumber,
    required this.driverName,
    required this.shift,
    required this.destinationSchool,
    this.status = 'scheduled',
    this.currentStopIndex = 0,
    this.delayMinutes = 0,
    required this.stops,
    this.startedAt,
    this.completedAt,
  });

  RouteStop? get currentStop =>
      currentStopIndex < stops.length ? stops[currentStopIndex] : null;

  RouteStop? get nextStop =>
      (currentStopIndex + 1) < stops.length ? stops[currentStopIndex + 1] : null;

  int get totalStudents => stops.fold(0, (sum, stop) => sum + stop.studentCount);
}

