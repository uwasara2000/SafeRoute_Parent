import '../models/child_model.dart';
import '../models/journey_model.dart';

enum JourneyFilter { all, morning, afternoon }

abstract class JourneyService {
  /// Fetches the list of children registered under the authenticated parent.
  Future<List<Child>> getChildren();

  /// Fetches journeys for a specific child, optionally filtered by type.
  Future<List<Journey>> getJourneys(String childId, {JourneyFilter filter = JourneyFilter.all});

  /// Fetches the current active journey status for a child, if any.
  Future<Journey?> getCurrentJourneyStatus(String childId);
}
