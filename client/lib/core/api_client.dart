import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'navigation_service.dart';
import 'constants.dart';

class ApiClient {
  static const int timeoutSeconds = 15;

  static void _logRequest(String method, String endpoint, {Map<String, dynamic>? body}) {
    debugPrint('API_REQ: [$method] ${AppConstants.baseUrl}$endpoint');
    if (body != null) {
      debugPrint('API_REQ_BODY: ${jsonEncode(body)}');
    }
  }

  static void _logResponse(http.Response response) {
    debugPrint('API_RES: [${response.statusCode}] ${response.request?.url}');
    debugPrint('API_RES_BODY: ${response.body}');
  }

  static Future<dynamic> get(String endpoint) async {
    _logRequest('GET', endpoint);
    try {
      final response = await http
          .get(Uri.parse('${AppConstants.baseUrl}$endpoint'))
          .timeout(const Duration(seconds: timeoutSeconds));
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API_ERR: $e');
      NavigationService.showSnackbar('Connection error or timeout');
      return {'success': false, 'message': 'Connection error or timeout', 'error': e.toString()};
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    _logRequest('POST', endpoint, body: body);
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: timeoutSeconds));
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API_ERR: $e');
      NavigationService.showSnackbar('Connection error or timeout');
      return {'success': false, 'message': 'Connection error or timeout', 'error': e.toString()};
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    _logRequest('PUT', endpoint, body: body);
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: timeoutSeconds));
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API_ERR: $e');
      NavigationService.showSnackbar('Connection error or timeout');
      return {'success': false, 'message': 'Connection error or timeout', 'error': e.toString()};
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    _logRequest('DELETE', endpoint);
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
      ).timeout(const Duration(seconds: timeoutSeconds));
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API_ERR: $e');
      NavigationService.showSnackbar('Connection error or timeout');
      return {'success': false, 'message': 'Connection error or timeout', 'error': e.toString()};
    }
  }

  static dynamic _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      NavigationService.showSnackbar('API Error: ${response.statusCode}');
      return {
        'success': false,
        'message': 'API Error: ${response.statusCode}',
        'error': response.body,
      };
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      if (response.statusCode == 422) {
        // Validation error, don't show snackbar here as it will be shown under fields
        NavigationService.showSnackbar(decoded['message'] ?? 'Validation error');
      } else {
        String errorMessage = 'API Error: ${response.statusCode}';
        if (decoded['message'] is String && decoded['message'].isNotEmpty) {
          errorMessage = decoded['message'];
        } else if (decoded['error'] is String && decoded['error'].isNotEmpty) {
          errorMessage = decoded['error'];
        }
        NavigationService.showSnackbar(errorMessage);
      }
      return decoded;
    }
  }
}
