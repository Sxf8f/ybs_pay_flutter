import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'tokenManager.dart';
import '../navigation/appNavigator.dart';

/// Custom HTTP client that handles token refresh automatically
class AuthenticatedHttpClient {
  // Timeout duration for requests (30 seconds)
  static const Duration _timeout = Duration(seconds: 30);
  
  // Get HTTP client with proper SSL handling
  // Handles SSL certificate chain issues (missing intermediate certificates)
  static http.Client _getHttpClient() {
    // Create a custom HttpClient that handles SSL certificate validation issues
    // This is needed when the server's SSL certificate chain is incomplete
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Log the certificate issue for debugging
        print('⚠️ [SSL] Certificate validation issue for $host:$port');
        print('   Certificate subject: ${cert.subject}');
        print('   Certificate issuer: ${cert.issuer}');
        
        // For production, you should fix the SSL certificate on the server
        // This workaround allows the connection but logs a warning
        // TODO: Fix SSL certificate chain on server (add intermediate certificates)
        
        // Allow the certificate (workaround for incomplete certificate chain)
        // WARNING: This reduces security - fix the server certificate ASAP
        return true;
      };
    
    return IOClient(httpClient);
  }

  /// Make a GET request with automatic token refresh
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    return _makeRequest(
      () async {
        final token = await TokenManager.getValidToken();
        if (token == null) {
          throw Exception('No valid token available. Please login again.');
        }

        final requestHeaders = Map<String, String>.from(headers ?? {});
        requestHeaders['Authorization'] = 'Bearer $token';
        requestHeaders['Content-Type'] = requestHeaders['Content-Type'] ?? 'application/json';

        print('🌐 [HTTP] GET Request: ${url.toString()}');
        
        try {
          final client = _getHttpClient();
          final response = await client
              .get(url, headers: requestHeaders)
              .timeout(_timeout);
          client.close();
          
          print('✅ [HTTP] Response Status: ${response.statusCode}');
          return response;
        } catch (e) {
          print('❌ [HTTP] GET Error: $e');
          if (e is SocketException) {
            throw Exception('Network error: Unable to connect to server. Please check your internet connection.');
          } else if (e is HttpException) {
            throw Exception('HTTP error: ${e.message}');
          } else if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
            throw Exception('Request timeout: Server took too long to respond. Please try again.');
          } else if (e.toString().contains('Certificate') || e.toString().contains('SSL')) {
            throw Exception('SSL certificate error: Please ensure the server has a valid SSL certificate.');
          }
          rethrow;
        }
      },
      retryOn401: retryOn401,
      url: url,
    );
  }

  /// Make a POST request with automatic token refresh
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool retryOn401 = true,
  }) async {
    return _makeRequest(
      () async {
        final token = await TokenManager.getValidToken();
        if (token == null) {
          throw Exception('No valid token available. Please login again.');
        }

        final requestHeaders = Map<String, String>.from(headers ?? {});
        requestHeaders['Authorization'] = 'Bearer $token';
        if (!requestHeaders.containsKey('Content-Type')) {
          requestHeaders['Content-Type'] = 'application/json';
        }

        final bodyString = body is String ? body : jsonEncode(body);
        
        print('🌐 [HTTP] POST Request: ${url.toString()}');
        
        try {
          final client = _getHttpClient();
          final response = await client
              .post(url, headers: requestHeaders, body: bodyString)
              .timeout(_timeout);
          client.close();
          
          print('✅ [HTTP] Response Status: ${response.statusCode}');
          return response;
        } catch (e) {
          print('❌ [HTTP] POST Error: $e');
          if (e is SocketException) {
            throw Exception('Network error: Unable to connect to server. Please check your internet connection.');
          } else if (e is HttpException) {
            throw Exception('HTTP error: ${e.message}');
          } else if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
            throw Exception('Request timeout: Server took too long to respond. Please try again.');
          } else if (e.toString().contains('Certificate') || e.toString().contains('SSL')) {
            throw Exception('SSL certificate error: Please ensure the server has a valid SSL certificate.');
          }
          rethrow;
        }
      },
      retryOn401: retryOn401,
      url: url,
    );
  }

  /// Make a PUT request with automatic token refresh
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool retryOn401 = true,
  }) async {
    return _makeRequest(
      () async {
        final token = await TokenManager.getValidToken();
        if (token == null) {
          throw Exception('No valid token available. Please login again.');
        }

        final requestHeaders = Map<String, String>.from(headers ?? {});
        requestHeaders['Authorization'] = 'Bearer $token';
        if (!requestHeaders.containsKey('Content-Type')) {
          requestHeaders['Content-Type'] = 'application/json';
        }

        final bodyString = body is String ? body : jsonEncode(body);
        
        try {
          final client = _getHttpClient();
          final response = await client
              .put(url, headers: requestHeaders, body: bodyString)
              .timeout(_timeout);
          client.close();
          return response;
        } catch (e) {
          if (e is SocketException) {
            throw Exception('Network error: Unable to connect to server.');
          } else if (e.toString().contains('timeout')) {
            throw Exception('Request timeout: Server took too long to respond.');
          }
          rethrow;
        }
      },
      retryOn401: retryOn401,
      url: url,
    );
  }

  /// Make a PATCH request with automatic token refresh
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool retryOn401 = true,
  }) async {
    return _makeRequest(
      () async {
        final token = await TokenManager.getValidToken();
        if (token == null) {
          throw Exception('No valid token available. Please login again.');
        }

        final requestHeaders = Map<String, String>.from(headers ?? {});
        requestHeaders['Authorization'] = 'Bearer $token';
        if (!requestHeaders.containsKey('Content-Type')) {
          requestHeaders['Content-Type'] = 'application/json';
        }

        final bodyString = body is String ? body : jsonEncode(body);
        
        try {
          final client = _getHttpClient();
          final response = await client
              .patch(url, headers: requestHeaders, body: bodyString)
              .timeout(_timeout);
          client.close();
          return response;
        } catch (e) {
          if (e is SocketException) {
            throw Exception('Network error: Unable to connect to server.');
          } else if (e.toString().contains('timeout')) {
            throw Exception('Request timeout: Server took too long to respond.');
          }
          rethrow;
        }
      },
      retryOn401: retryOn401,
      url: url,
    );
  }

  /// Make a DELETE request with automatic token refresh
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    return _makeRequest(
      () async {
        final token = await TokenManager.getValidToken();
        if (token == null) {
          throw Exception('No valid token available. Please login again.');
        }

        final requestHeaders = Map<String, String>.from(headers ?? {});
        requestHeaders['Authorization'] = 'Bearer $token';
        requestHeaders['Content-Type'] = requestHeaders['Content-Type'] ?? 'application/json';

        try {
          final client = _getHttpClient();
          final response = await client
              .delete(url, headers: requestHeaders)
              .timeout(_timeout);
          client.close();
          return response;
        } catch (e) {
          if (e is SocketException) {
            throw Exception('Network error: Unable to connect to server.');
          } else if (e.toString().contains('timeout')) {
            throw Exception('Request timeout: Server took too long to respond.');
          }
          rethrow;
        }
      },
      retryOn401: retryOn401,
      url: url,
    );
  }

  /// Internal method to handle requests with automatic retry on 401
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() request, {
    required bool retryOn401,
    Uri? url,
  }) async {
    try {
      var response = await request();

      // If 401 and retry is enabled, try to refresh token and retry once
      if (response.statusCode == 401 && retryOn401) {
        print('⚠️ [HTTP] Received 401, attempting token refresh...');
        
        final refreshed = await TokenManager.refreshToken();
        if (refreshed) {
          print('✅ [HTTP] Token refreshed, retrying request...');
          // Retry the request with new token
          response = await request();
        } else {
          // Refresh failed (expired / invalidated). Force global logout
          // and then throw to let callers show any local error if needed.
          await AppNavigator.forceLogout(
            message: 'Your session has ended. Please login again.',
          );
          throw Exception('Session expired. Please login again.');
        }
      }

      // Log non-200 status codes for debugging
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('⚠️ [HTTP] Non-success status: ${response.statusCode}');
        if (url != null) {
          print('   URL: ${url.toString()}');
        }
        print('   Response body: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
      }

      return response;
    } catch (e, stackTrace) {
      print('❌ [HTTP] Request failed: $e');
      if (url != null) {
        print('   URL: ${url.toString()}');
      }
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get token for manual use (e.g., multipart requests)
  static Future<String?> getToken() async {
    return await TokenManager.getValidToken();
  }
  
  /// Get an SSL-aware HTTP client for unauthenticated requests
  /// Use this for public endpoints that don't require authentication
  static http.Client getSslAwareClient() {
    return _getHttpClient();
  }
}

