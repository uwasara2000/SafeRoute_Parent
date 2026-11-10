import '../models/child_model.dart';
import '../models/journey_model.dart';
import 'journey_service.dart';

class MockJourneyService implements JourneyService {
  static const String amayaId = 'child_001';
  static const String kevinId = 'child_002';

  @override
  Future<List<Child>> getChildren() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Child(id: amayaId, name: 'Amaya Silva'),
      Child(id: kevinId, name: 'Kevin Silva'),
    ];
  }

  @override
  Future<List<Journey>> getJourneys(
    String childId, {
    JourneyFilter filter = JourneyFilter.all,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final journeys = _getJourneysForChild(childId);

    switch (filter) {
      case JourneyFilter.all:
        return journeys;
      case JourneyFilter.morning:
        return journeys
            .where((journey) => journey.journeyType == JourneyType.morning)
            .toList();
      case JourneyFilter.afternoon:
        return journeys
            .where((journey) => journey.journeyType == JourneyType.afternoon)
            .toList();
    }
  }

  @override
  Future<Journey?> getCurrentJourneyStatus(String childId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (childId == amayaId) {
      return Journey(
        id: 'journey_active_001',
        childId: amayaId,
        journeyType: JourneyType.morning,
        status: JourneyStatus.inProgress,
        routeName: 'Route 08',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 7, 15),
        endTime: null,
        boardingTime: DateTime(today.year, today.month, today.day, 7, 18),
        dropOffTime: null,
        lastUpdated: now.subtract(const Duration(minutes: 2)),
        statusMessage: 'In transit - Route 08',
      );
    } else if (childId == kevinId) {
      return Journey(
        id: 'journey_active_002',
        childId: kevinId,
        journeyType: JourneyType.morning,
        status: JourneyStatus.inProgress,
        routeName: 'Route 03',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 7, 25),
        endTime: null,
        boardingTime: DateTime(today.year, today.month, today.day, 7, 28),
        dropOffTime: null,
        lastUpdated: now.subtract(const Duration(minutes: 3)),
        statusMessage: 'In transit - Route 03',
      );
    }

    return null;
  }

  List<Journey> _getJourneysForChild(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final threeDaysAgo = today.subtract(const Duration(days: 3));
    final fourDaysAgo = today.subtract(const Duration(days: 4));
    final fiveDaysAgo = today.subtract(const Duration(days: 5));

    if (childId == amayaId) {
      return [
        // Journey 1: Morning journey, Today 18 June, Route 08, 7:16 AM - 7:52 AM, Completed
        Journey(
          id: 'journey_amaya_001',
          childId: amayaId,
          journeyType: JourneyType.morning,
          status: JourneyStatus.completed,
          routeName: 'Route 08',
          date: today,
          startTime: DateTime(today.year, today.month, today.day, 7, 16),
          endTime: DateTime(today.year, today.month, today.day, 7, 52),
          boardingTime: DateTime(today.year, today.month, today.day, 7, 18),
          dropOffTime: DateTime(today.year, today.month, today.day, 7, 50),
          lastUpdated: now.subtract(const Duration(minutes: 10)),
          statusMessage: 'Student dropped off safely at school',
        ),
        // Journey 2: Return journey, Mon 17 June, Route 08, 1:34 PM - 2:12 PM, Completed
        Journey(
          id: 'journey_amaya_002',
          childId: amayaId,
          journeyType: JourneyType.afternoon,
          status: JourneyStatus.completed,
          routeName: 'Route 08',
          date: yesterday,
          startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 34),
          endTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 12),
          boardingTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 36),
          dropOffTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 10),
          lastUpdated: yesterday.add(const Duration(hours: 14, minutes: 15)),
          statusMessage: 'Student arrived home safely',
        ),
        // Journey 3: Morning journey, Fri 14 June, Route 08, Cancelled (no times)
        Journey(
          id: 'journey_amaya_003',
          childId: amayaId,
          journeyType: JourneyType.morning,
          status: JourneyStatus.cancelled,
          routeName: 'Route 08',
          date: fourDaysAgo,
          startTime: null,
          endTime: null,
          boardingTime: null,
          dropOffTime: null,
          lastUpdated: fourDaysAgo.add(const Duration(hours: 7)),
          statusMessage: 'Cancelled by parent',
        ),
        // Journey 4: Return journey, 5 days ago, Route 08, 1:30 PM - 2:08 PM, Completed
        Journey(
          id: 'journey_amaya_004',
          childId: amayaId,
          journeyType: JourneyType.afternoon,
          status: JourneyStatus.completed,
          routeName: 'Route 08',
          date: fiveDaysAgo,
          startTime: DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day, 13, 30),
          endTime: DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day, 14, 8),
          boardingTime: DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day, 13, 33),
          dropOffTime: DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day, 14, 6),
          lastUpdated: fiveDaysAgo.add(const Duration(hours: 14, minutes: 10)),
          statusMessage: 'Student arrived home safely',
        ),
      ];
    } else if (childId == kevinId) {
      return [
        Journey(
          id: 'journey_kevin_001',
          childId: kevinId,
          journeyType: JourneyType.morning,
          status: JourneyStatus.completed,
          routeName: 'Route 03',
          date: today,
          startTime: DateTime(today.year, today.month, today.day, 7, 24),
          endTime: DateTime(today.year, today.month, today.day, 8, 1),
          boardingTime: DateTime(today.year, today.month, today.day, 7, 27),
          dropOffTime: DateTime(today.year, today.month, today.day, 7, 59),
          lastUpdated: now.subtract(const Duration(minutes: 20)),
          statusMessage: 'Student dropped off safely at school',
        ),
        Journey(
          id: 'journey_kevin_002',
          childId: kevinId,
          journeyType: JourneyType.afternoon,
          status: JourneyStatus.completed,
          routeName: 'Route 03',
          date: yesterday,
          startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 45),
          endTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 22),
          boardingTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 48),
          dropOffTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 20),
          lastUpdated: yesterday.add(const Duration(hours: 14, minutes: 25)),
          statusMessage: 'Student arrived home safely',
        ),
        Journey(
          id: 'journey_kevin_003',
          childId: kevinId,
          journeyType: JourneyType.morning,
          status: JourneyStatus.completed,
          routeName: 'Route 03',
          date: threeDaysAgo,
          startTime: DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 7, 20),
          endTime: DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 7, 58),
          boardingTime: DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 7, 23),
          dropOffTime: DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 7, 56),
          lastUpdated: threeDaysAgo.add(const Duration(hours: 8)),
          statusMessage: 'Student dropped off safely at school',
        ),
        Journey(
          id: 'journey_kevin_004',
          childId: kevinId,
          journeyType: JourneyType.afternoon,
          status: JourneyStatus.completed,
          routeName: 'Route 03',
          date: fourDaysAgo,
          startTime: DateTime(fourDaysAgo.year, fourDaysAgo.month, fourDaysAgo.day, 13, 40),
          endTime: DateTime(fourDaysAgo.year, fourDaysAgo.month, fourDaysAgo.day, 14, 18),
          boardingTime: DateTime(fourDaysAgo.year, fourDaysAgo.month, fourDaysAgo.day, 13, 42),
          dropOffTime: DateTime(fourDaysAgo.year, fourDaysAgo.month, fourDaysAgo.day, 14, 15),
          lastUpdated: fourDaysAgo.add(const Duration(hours: 14, minutes: 20)),
          statusMessage: 'Student arrived home safely',
        ),
      ];
    }

    return [];
  }
}
