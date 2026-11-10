import 'package:flutter_test/flutter_test.dart';
import 'package:parent_app/features/history/models/journey.dart';

void main() {
  group('JourneyStatus parsing', () {
    test('parseStatus maps known string values correctly', () {
      expect(Journey.parseStatus('completed'), JourneyStatus.completed);
      expect(Journey.parseStatus('cancelled'), JourneyStatus.cancelled);
      expect(Journey.parseStatus('in_progress'), JourneyStatus.inProgress);
      expect(Journey.parseStatus('scheduled'), JourneyStatus.scheduled);
    });

    test('parseStatus returns unknown for null', () {
      expect(Journey.parseStatus(null), JourneyStatus.unknown);
    });

    test('parseStatus returns unknown for unrecognised values', () {
      expect(Journey.parseStatus('something_else'), JourneyStatus.unknown);
      expect(Journey.parseStatus(''), JourneyStatus.unknown);
    });
  });

  group('JourneyType parsing', () {
    test('parseJourneyType maps known values', () {
      expect(Journey.parseJourneyType('morning'), JourneyType.morning);
      expect(Journey.parseJourneyType('afternoon'), JourneyType.afternoon);
    });

    test('parseJourneyType defaults to morning for null or unknown', () {
      expect(Journey.parseJourneyType(null), JourneyType.morning);
      expect(Journey.parseJourneyType('evening'), JourneyType.morning);
    });
  });

  group('Journey.fromJson', () {
    test('parses a complete JSON object', () {
      final json = {
        'id': 'j1',
        'child_id': 'c1',
        'journey_type': 'morning',
        'status': 'completed',
        'route_name': 'Route 08',
        'date': '2026-06-18T00:00:00.000',
        'start_time': '2026-06-18T07:16:00.000',
        'end_time': '2026-06-18T07:52:00.000',
        'boarding_time': '2026-06-18T07:18:00.000',
        'drop_off_time': '2026-06-18T07:50:00.000',
        'last_updated': '2026-06-18T07:52:00.000',
        'status_message': 'Journey completed successfully',
      };

      final journey = Journey.fromJson(json);

      expect(journey.id, 'j1');
      expect(journey.childId, 'c1');
      expect(journey.journeyType, JourneyType.morning);
      expect(journey.status, JourneyStatus.completed);
      expect(journey.routeName, 'Route 08');
      expect(journey.date, isNotNull);
      expect(journey.startTime, isNotNull);
      expect(journey.endTime, isNotNull);
      expect(journey.boardingTime, isNotNull);
      expect(journey.dropOffTime, isNotNull);
      expect(journey.lastUpdated, isNotNull);
      expect(journey.statusMessage, 'Journey completed successfully');
    });

    test('handles missing optional fields gracefully', () {
      final json = {'id': 'j2', 'child_id': 'c1', 'status': 'cancelled'};

      final journey = Journey.fromJson(json);

      expect(journey.id, 'j2');
      expect(journey.childId, 'c1');
      expect(journey.status, JourneyStatus.cancelled);
      expect(journey.routeName, isNull);
      expect(journey.date, isNull);
      expect(journey.startTime, isNull);
      expect(journey.endTime, isNull);
      expect(journey.boardingTime, isNull);
      expect(journey.dropOffTime, isNull);
      expect(journey.lastUpdated, isNull);
      expect(journey.statusMessage, isNull);
    });

    test('handles empty JSON object without crashing', () {
      final json = <String, dynamic>{};

      final journey = Journey.fromJson(json);

      expect(journey.id, '');
      expect(journey.childId, '');
      expect(journey.status, JourneyStatus.unknown);
      expect(journey.journeyType, JourneyType.morning);
    });

    test('handles invalid date strings without crashing', () {
      final json = {
        'id': 'j3',
        'child_id': 'c1',
        'date': 'not-a-date',
        'start_time': 'invalid',
        'last_updated': '12345',
      };

      final journey = Journey.fromJson(json);

      expect(journey.date, isNull);
      expect(journey.startTime, isNull);
      expect(journey.lastUpdated, isNull);
    });
  });

  group('Journey getters', () {
    test('statusLabel returns correct labels', () {
      Journey makeJourney(JourneyStatus status) => Journey(
        id: '1',
        childId: '1',
        journeyType: JourneyType.morning,
        status: status,
      );

      expect(makeJourney(JourneyStatus.completed).statusLabel, 'Completed');
      expect(makeJourney(JourneyStatus.cancelled).statusLabel, 'Cancelled');
      expect(makeJourney(JourneyStatus.inProgress).statusLabel, 'In Progress');
      expect(makeJourney(JourneyStatus.scheduled).statusLabel, 'Scheduled');
      expect(makeJourney(JourneyStatus.unknown).statusLabel, 'Unknown');
    });

    test('journeyTitle returns correct titles', () {
      final morning = Journey(
        id: '1',
        childId: '1',
        journeyType: JourneyType.morning,
        status: JourneyStatus.completed,
      );
      final afternoon = Journey(
        id: '2',
        childId: '1',
        journeyType: JourneyType.afternoon,
        status: JourneyStatus.completed,
      );

      expect(morning.journeyTitle, 'Morning journey');
      expect(afternoon.journeyTitle, 'Return journey');
    });
  });
}
