import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Custom HTTP client that handles SSL certificate validation issues
/// This is useful for development/testing with self-signed certificates
class SslHttpClient {
  static http.Client? _client;

  /// Get an HTTP client that bypasses SSL certificate validation
  /// WARNING: Only use this for development/testing. Not recommended for production.
  static http.Client getClient({bool allowBadCertificates = true}) {
    if (_client != null && !allowBadCertificates) {
      return http.Client();
    }

    if (allowBadCertificates) {
      final httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Allow all certificates (for development/testing only)
          print('⚠️ [SSL] Bypassing certificate validation for $host:$port');
          return true;
        };

      _client = IOClient(httpClient);
      return _client!;
    }

    return http.Client();
  }

  /// Reset the client (useful for testing)
  static void reset() {
    _client?.close();
    _client = null;
  }
}
