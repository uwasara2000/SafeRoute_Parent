enum JourneyStatus {
  completed,
  cancelled,
  inProgress,
  scheduled,
  unknown,
}

enum JourneyType {
  morning,
  afternoon,
}

class Journey {
  final String id;
  final String childId;
  final JourneyType journeyType;
  final JourneyStatus status;
  final String? routeName;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? boardingTime;
  final DateTime? dropOffTime;
  final DateTime? lastUpdated;
  final String? statusMessage;

  const Journey({
    required this.id,
    required this.childId,
    required this.journeyType,
    required this.status,
    this.routeName,
    this.date,
    this.startTime,
    this.endTime,
    this.boardingTime,
    this.dropOffTime,
    this.lastUpdated,
    this.statusMessage,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id']?.toString() ?? '',
      childId: (json['child_id'] ?? json['childId'])?.toString() ?? '',
      journeyType: parseJourneyType(
        (json['journey_type'] ?? json['journeyType'] ?? json['type'])?.toString(),
      ),
      status: parseStatus(
        (json['status'] ?? json['journey_status'] ?? json['journeyStatus'])?.toString(),
      ),
      routeName: (json['route_name'] ?? json['routeName'])?.toString(),
      date: _tryParseDateTime(json['date']),
      startTime: _tryParseDateTime(json['start_time'] ?? json['startTime']),
      endTime: _tryParseDateTime(json['end_time'] ?? json['endTime']),
      boardingTime: _tryParseDateTime(json['boarding_time'] ?? json['boardingTime']),
      dropOffTime: _tryParseDateTime(json['drop_off_time'] ?? json['dropOffTime']),
      lastUpdated: _tryParseDateTime(json['last_updated'] ?? json['lastUpdated']),
      statusMessage: (json['status_message'] ?? json['statusMessage'])?.toString(),
    );
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String get statusLabel {
    switch (status) {
      case JourneyStatus.completed:
        return 'Completed';
      case JourneyStatus.cancelled:
        return 'Cancelled';
      case JourneyStatus.inProgress:
        return 'In Progress';
      case JourneyStatus.scheduled:
        return 'Scheduled';
      case JourneyStatus.unknown:
        return 'Unknown';
    }
  }

  String get journeyTitle {
    switch (journeyType) {
      case JourneyType.morning:
        return 'Morning journey';
      case JourneyType.afternoon:
        return 'Return journey';
    }
  }

  static JourneyStatus parseStatus(String? value) {
    if (value == null) return JourneyStatus.unknown;
    final normalized = value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'completed':
        return JourneyStatus.completed;
      case 'cancelled':
      case 'canceled':
        return JourneyStatus.cancelled;
      case 'in_progress':
      case 'inprogress':
        return JourneyStatus.inProgress;
      case 'scheduled':
        return JourneyStatus.scheduled;
      default:
        return JourneyStatus.unknown;
    }
  }

  static JourneyType parseJourneyType(String? value) {
    if (value == null) return JourneyType.morning;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'afternoon':
      case 'return':
        return JourneyType.afternoon;
      case 'morning':
      default:
        return JourneyType.morning;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'child_id': childId,
    'journey_type': journeyType.name,
    'status': status.name,
    if (routeName != null) 'route_name': routeName,
    if (date != null) 'date': date!.toIso8601String(),
    if (startTime != null) 'start_time': startTime!.toIso8601String(),
    if (endTime != null) 'end_time': endTime!.toIso8601String(),
    if (boardingTime != null) 'boarding_time': boardingTime!.toIso8601String(),
    if (dropOffTime != null) 'drop_off_time': dropOffTime!.toIso8601String(),
    if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
    if (statusMessage != null) 'status_message': statusMessage,
  };
}
