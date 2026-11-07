class RouteStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int sequence;
  final String scheduledTime;
  final int studentCount;
  bool isCompleted;

  RouteStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    required this.scheduledTime,
    this.studentCount = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'sequence': sequence,
    'scheduledTime': scheduledTime,
    'studentCount': studentCount,
    'isCompleted': isCompleted,
  };

  factory RouteStop.fromMap(Map<String, dynamic> map) => RouteStop(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    sequence: (map['sequence'] as num?)?.toInt() ?? 0,
    scheduledTime: map['scheduledTime'] ?? '',
    studentCount: (map['studentCount'] as num?)?.toInt() ?? 0,
    isCompleted: map['isCompleted'] ?? false,
  );
}

