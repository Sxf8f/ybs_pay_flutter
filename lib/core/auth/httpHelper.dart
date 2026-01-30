import 'package:http/http.dart' as http;
import 'tokenManager.dart';
import 'httpClient.dart';

/// Helper class for making authenticated HTTP requests
/// This wraps the AuthenticatedHttpClient and provides easy-to-use methods
class HttpHelper {
  /// Make a GET request with automatic token refresh
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return await AuthenticatedHttpClient.get(
      Uri.parse(url),
      headers: headers,
    );
  }

  /// Make a POST request with automatic token refresh
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await AuthenticatedHttpClient.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
  }

  /// Make a PUT request with automatic token refresh
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await AuthenticatedHttpClient.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
  }

  /// Make a PATCH request with automatic token refresh
  static Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await AuthenticatedHttpClient.patch(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
  }

  /// Make a DELETE request with automatic token refresh
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    return await AuthenticatedHttpClient.delete(
      Uri.parse(url),
      headers: headers,
    );
  }

  /// Get token for manual use (e.g., multipart requests)
  static Future<String?> getToken() async {
    return await TokenManager.getValidToken();
  }

  /// Add authorization header to existing headers
  static Future<Map<String, String>> addAuthHeader(Map<String, String> headers) async {
    final token = await TokenManager.getValidToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}

