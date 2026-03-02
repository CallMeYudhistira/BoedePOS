import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiClient {
  static const int timeoutSeconds = 15;

  static void _logRequest(String method, String endpoint, {Map<String, dynamic>? body}) {
    developer.log('[$method] ${AppConstants.baseUrl}$endpoint', name: 'API_REQ');
    if (body != null) {
      developer.log('BODY: ${jsonEncode(body)}', name: 'API_REQ');
    }
  }

  static void _logResponse(http.Response response) {
    developer.log('[${response.statusCode}] ${response.request?.url}', name: 'API_RES');
    developer.log('BODY: ${response.body}', name: 'API_RES');
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
      developer.log('ERROR: $e', name: 'API_ERR');
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
      developer.log('ERROR: $e', name: 'API_ERR');
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
      developer.log('ERROR: $e', name: 'API_ERR');
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
      developer.log('ERROR: $e', name: 'API_ERR');
      return {'success': false, 'message': 'Connection error or timeout', 'error': e.toString()};
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // Prevent throwing an exception so the app doesn't freeze
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {
          'success': false,
          'message': 'API Error: ${response.statusCode}',
          'error': response.body,
        };
      }
    }
  }
}
