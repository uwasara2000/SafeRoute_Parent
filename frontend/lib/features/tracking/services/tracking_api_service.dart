import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/trip_details.dart';
import '../models/trip_event.dart';

class TrackingApiException implements Exception {
  final String message;
  final int? statusCode;

  const TrackingApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class TrackingApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  final http.Client _client;
  final String _baseUrl;

  TrackingApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = _normalizeBaseUrl(
        baseUrl?.trim().isNotEmpty == true
            ? baseUrl!.trim()
            : _configuredBaseUrl.isNotEmpty
            ? _configuredBaseUrl
            : _defaultBaseUrl(),
      );

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  static String _normalizeBaseUrl(String value) {
    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const TrackingApiException(
        'Sign in to access trip information.',
        statusCode: 401,
      );
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw const TrackingApiException(
        'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _get(String path) async {
    return _client
        .get(Uri.parse('$_baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 8));
  }

  Future<http.Response> _put(String path, Map<String, dynamic> body) async {
    return _client
        .put(
          Uri.parse('$_baseUrl$path'),
          headers: await _headers(),
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 8));
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = switch (response.statusCode) {
        400 => 'The trip request contains invalid or unavailable data.',
        401 => 'Your session has expired. Please sign in again.',
        403 => 'You do not have access to this trip.',
        404 => 'Trip information is not available.',
        _ => 'The tracking service is unavailable. Please try again.',
      };
      throw TrackingApiException(message, statusCode: response.statusCode);
    }

    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      throw const TrackingApiException(
        'The tracking service returned invalid data.',
      );
    }
    throw const TrackingApiException(
      'The tracking service returned invalid data.',
    );
  }

  String _tripPath(String tripId, [String? suffix]) {
    final encodedTripId = Uri.encodeComponent(tripId);
    return '/api/parent/trips/$encodedTripId${suffix ?? ''}';
  }

  Future<TripDetails> fetchTripDetails(String tripId) async {
    final response = await _get(_tripPath(tripId));
    return TripDetails.fromMap(_decodeObject(response));
  }

  Future<EtaInfo> fetchETA(String tripId) async {
    final response = await _get(_tripPath(tripId, '/eta'));
    return EtaInfo.fromMap(_decodeObject(response));
  }

  Future<List<TripEvent>> fetchEvents(String tripId) async {
    final response = await _get(_tripPath(tripId, '/events'));
    final data = _decodeObject(response);
    final events = data['events'];
    if (events is! List) {
      throw const TrackingApiException(
        'The tracking service returned invalid event data.',
      );
    }

    return events
        .whereType<Map<String, dynamic>>()
        .map(TripEvent.fromMap)
        .toList()
      ..sort((left, right) {
        final leftTime = left.timestamp;
        final rightTime = right.timestamp;
        if (leftTime == null) return 1;
        if (rightTime == null) return -1;
        return rightTime.compareTo(leftTime);
      });
  }

  Future<TripDetails> updateStops({
    required String tripId,
    Map<String, dynamic>? pickup,
    Map<String, dynamic>? destination,
  }) async {
    final response = await _put(_tripPath(tripId, '/stops'), {
      if (pickup != null) 'pickup': pickup,
      if (destination != null) 'destination': destination,
    });
    final data = _decodeObject(response);
    final trip = data['trip'];
    if (trip is! Map<String, dynamic>) {
      throw const TrackingApiException(
        'The tracking service returned invalid trip data.',
      );
    }
    return TripDetails.fromMap(trip);
  }

  void dispose() {
    _client.close();
  }
}
