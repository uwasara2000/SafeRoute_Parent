import 'package:flutter_test/flutter_test.dart';
import 'package:parent_app/features/history/utils/date_formatter.dart';

void main() {
  group('formatJourneyDate', () {
    test('returns "--" for null', () {
      expect(formatJourneyDate(null), '--');
    });

    test('returns "Today, DD MMMM" for today', () {
      final now = DateTime.now();
      final result = formatJourneyDate(now);
      expect(result, startsWith('Today, '));
    });

    test('returns weekday format for other dates', () {
      // Use a fixed past date
      final date = DateTime(2026, 6, 17); // A Wednesday
      final result = formatJourneyDate(date);
      expect(result, contains('17'));
      expect(result, contains('June'));
    });
  });

  group('formatTime', () {
    test('returns "--" for null', () {
      expect(formatTime(null), '--');
    });

    test('formats time correctly', () {
      final time = DateTime(2026, 6, 18, 7, 16);
      final result = formatTime(time);
      expect(result, contains('7'));
      expect(result, contains('16'));
      expect(result, contains('AM'));
    });

    test('formats PM time correctly', () {
      final time = DateTime(2026, 6, 18, 13, 34);
      final result = formatTime(time);
      expect(result, contains('1'));
      expect(result, contains('34'));
      expect(result, contains('PM'));
    });
  });

  group('formatTimeRange', () {
    test('returns "--" when both times are null', () {
      expect(formatTimeRange(null, null), '--');
    });

    test('formats range when both times present', () {
      final start = DateTime(2026, 6, 18, 7, 16);
      final end = DateTime(2026, 6, 18, 7, 52);
      final result = formatTimeRange(start, end);
      expect(result, contains('7'));
      expect(result, contains('16'));
      expect(result, contains('52'));
    });

    test('handles null end time', () {
      final start = DateTime(2026, 6, 18, 7, 16);
      final result = formatTimeRange(start, null);
      expect(result, contains('7'));
      expect(result, contains('16'));
    });

    test('handles null start time', () {
      final end = DateTime(2026, 6, 18, 7, 52);
      final result = formatTimeRange(null, end);
      expect(result, isNotEmpty);
    });
  });

  group('formatLastUpdated', () {
    test('returns empty string for null', () {
      expect(formatLastUpdated(null), '');
    });

    test('returns "Just now" for recent time', () {
      final now = DateTime.now();
      expect(formatLastUpdated(now), 'Just now');
    });

    test('returns minutes ago for times within an hour', () {
      final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
      final result = formatLastUpdated(fiveMinAgo);
      expect(result, contains('min ago'));
    });

    test('returns hours ago for times within a day', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      final result = formatLastUpdated(twoHoursAgo);
      expect(result, contains('hour'));
    });
  });
}
