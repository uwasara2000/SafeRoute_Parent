import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferoute_parent/models/child_model.dart';
import 'package:saferoute_parent/models/journey_model.dart';
import 'package:saferoute_parent/screens/journey_history_screen.dart';
import 'package:saferoute_parent/services/api_client.dart';
import 'package:saferoute_parent/services/journey_service.dart';

class FakeJourneyService implements JourneyService {
  final List<Child> children;
  final List<Journey> journeys;
  final bool shouldFail;

  FakeJourneyService({
    this.children = const [
      Child(id: 'child_001', name: 'Amaya Silva'),
      Child(id: 'child_002', name: 'Kevin Silva'),
    ],
    this.journeys = const [],
    this.shouldFail = false,
  });

  @override
  Future<List<Child>> getChildren() async {
    if (shouldFail) {
      throw const ApiException(
        type: ApiErrorType.network,
        message: 'No internet connection. Please check your network.',
      );
    }
    return children;
  }

  @override
  Future<List<Journey>> getJourneys(
    String childId, {
    JourneyFilter filter = JourneyFilter.all,
  }) async {
    if (shouldFail) {
      throw const ApiException(
        type: ApiErrorType.network,
        message: 'No internet connection. Please check your network.',
      );
    }
    return journeys;
  }

  @override
  Future<Journey?> getCurrentJourneyStatus(String childId) async {
    return null;
  }
}

void main() {
  testWidgets('displays loading indicator initially', (tester) async {
    final fakeService = FakeJourneyService();
    await tester.pumpWidget(
      MaterialApp(
        home: JourneyHistoryScreen(journeyService: fakeService),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Unmount to clean up timers
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('renders journey list with items and status badges', (tester) async {
    final testJourneys = [
      Journey(
        id: 'j1',
        childId: 'child_001',
        journeyType: JourneyType.morning,
        status: JourneyStatus.completed,
        routeName: 'Route 08',
        date: DateTime.now(),
        startTime: DateTime(2026, 6, 18, 7, 16),
        endTime: DateTime(2026, 6, 18, 7, 52),
        boardingTime: DateTime(2026, 6, 18, 7, 18),
        dropOffTime: DateTime(2026, 6, 18, 7, 50),
      ),
      Journey(
        id: 'j2',
        childId: 'child_001',
        journeyType: JourneyType.morning,
        status: JourneyStatus.cancelled,
        routeName: 'Route 08',
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    final fakeService = FakeJourneyService(journeys: testJourneys);
    await tester.pumpWidget(
      MaterialApp(
        home: JourneyHistoryScreen(journeyService: fakeService),
      ),
    );

    // Let async loading finish
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Amaya Silva'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Afternoon'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('Morning journey'), findsNWidgets(2));
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Boarded: 7:18 AM'), findsOneWidget);
    expect(find.text('Dropped off: 7:50 AM'), findsOneWidget);

    // Clean up
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('displays error view and allows retry on network failure', (tester) async {
    final failingService = FakeJourneyService(shouldFail: true);
    await tester.pumpWidget(
      MaterialApp(
        home: JourneyHistoryScreen(journeyService: failingService),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No internet connection. Please check your network.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Clean up
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
