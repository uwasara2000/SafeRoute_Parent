import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

enum ApiErrorType { unauthorized, network, server, unknown }

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;

  const ApiException({required this.type, required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($type): $message';
}

class ApiClient {
  final String baseUrl;
  final AuthService authService;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    required this.authService,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        type: ApiErrorType.network,
        message: 'No internet connection. Please check your network.',
      );
    } on http.ClientException {
      throw const ApiException(
        type: ApiErrorType.network,
        message: 'Network error. Please try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        try {
          return json.decode(response.body);
        } catch (_) {
          throw const ApiException(
            type: ApiErrorType.server,
            message: 'Invalid response format from server.',
          );
        }
      case 401:
        throw const ApiException(
          type: ApiErrorType.unauthorized,
          message: 'Session expired. Please log in again.',
          statusCode: 401,
        );
      case 403:
        throw const ApiException(
          type: ApiErrorType.unauthorized,
          message: 'You do not have permission to access this resource.',
          statusCode: 403,
        );
      default:
        throw ApiException(
          type: ApiErrorType.server,
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
