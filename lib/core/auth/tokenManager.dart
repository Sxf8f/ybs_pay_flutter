import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const/assets_const.dart';

class TokenManager {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiresAt = 'token_expires_at';
  
  static bool _isRefreshing = false;
  static DateTime? _lastRefreshAttempt;

  /// Get access token from storage
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Get refresh token from storage
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt(_keyTokenExpiresAt);
    
    if (expiresAt == null) {
      // If expiration time not stored, assume expired
      return true;
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiresAt;
  }

  /// Check if token is expiring soon (default: 5 minutes before expiration)
  static Future<bool> isTokenExpiringSoon({int minutesBefore = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt(_keyTokenExpiresAt);
    
    if (expiresAt == null) {
      return true;
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final threshold = expiresAt - (minutesBefore * 60 * 1000);
    return now >= threshold;
  }

  /// Validate token with backend (password reset / expiration aware)
  static Future<Map<String, dynamic>?> validateToken() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await http.post(
        Uri.parse('${AssetsConst.apiBase}api/android/auth/validate-token/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

          // Update expiration time if provided
          if (data['expires_at'] != null) {
            try {
              final expiresAt = DateTime.parse(data['expires_at']);
              final prefs = await SharedPreferences.getInstance();
            await prefs.setInt(
              _keyTokenExpiresAt,
              expiresAt.millisecondsSinceEpoch,
            );
            } catch (e) {
              print('Error parsing expires_at: $e');
            }
          }

        return data as Map<String, dynamic>;
      }
      
      print('Token validation failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error validating token: $e');
      return null;
    }
  }

  /// Refresh access token using refresh token
  /// [forceRefresh] - If true, bypasses rate limiting (use with caution)
  /// [maxRetries] - Maximum number of retries for temporary errors (default: 2)
  static Future<bool> refreshToken({bool forceRefresh = false, int maxRetries = 2}) async {
    // Prevent multiple simultaneous refresh calls
    if (_isRefreshing) {
      // Wait for ongoing refresh to complete
      int waitCount = 0;
      while (_isRefreshing && waitCount < 50) {
        await Future.delayed(Duration(milliseconds: 100));
        waitCount++;
      }
      // After waiting, check if token is still expired
      final stillExpired = await isTokenExpired();
      if (stillExpired) {
        // If still expired after waiting, the other refresh might have failed
        // Return false to allow caller to handle
        return false;
      }
      return true; // Other refresh succeeded
    }

    // Rate limiting: Don't refresh more than once per minute (unless forced)
    if (!forceRefresh && _lastRefreshAttempt != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshAttempt!);
      if (timeSinceLastRefresh.inSeconds < 60) {
        final secondsToWait = 60 - timeSinceLastRefresh.inSeconds;
        print('Token refresh rate limited. Waiting $secondsToWait seconds...');
        
        // If token is expired, we MUST wait and retry (don't just return false)
        final isExpired = await isTokenExpired();
        if (isExpired) {
          // Wait for the remaining time
          await Future.delayed(Duration(seconds: secondsToWait));
          // Retry after waiting
          return await refreshToken(forceRefresh: true, maxRetries: maxRetries);
        } else {
          // Token is not expired, so rate limiting is fine - return success
          return true;
        }
      }
    }

    _isRefreshing = true;
    _lastRefreshAttempt = DateTime.now();

    int retryCount = 0;
    while (retryCount <= maxRetries) {
      try {
        final refreshToken = await getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          print('No refresh token available');
          _isRefreshing = false;
          return false;
        }

        if (retryCount > 0) {
          print('Retrying token refresh (attempt ${retryCount + 1}/${maxRetries + 1})...');
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
        } else {
          print('Refreshing access token...');
        }

        final response = await http.post(
          Uri.parse('${AssetsConst.apiBase}api/refresh-token-android/'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'refresh_token': refreshToken,
          }),
        ).timeout(Duration(seconds: 30));

        print('Token refresh response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // If backend explicitly says the token was invalidated by password reset,
          // clear everything and force caller to treat this as logout.
          if (data['success'] == false &&
              (data['error']?.toString().toLowerCase() ??
                      '')
                  .contains('token invalidated by password reset')) {
            print('Refresh token invalidated by password reset. Clearing tokens.');
            await clearTokens();
            _isRefreshing = false;
            return false;
          }
          
          if (data['success'] == true) {
            final newAccessToken = data['access'] ?? data['token'];
            final newRefreshToken = data['refresh'];
            
            if (newAccessToken != null) {
              // Save new tokens
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_keyAccessToken, newAccessToken.toString());
              
              if (newRefreshToken != null) {
                await prefs.setString(_keyRefreshToken, newRefreshToken.toString());
              }

              // Calculate and store expiration time
              int expiresIn = data['expires_in'] ?? 7200; // Default 2 hours
              final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
              await prefs.setInt(_keyTokenExpiresAt, expiresAt.millisecondsSinceEpoch);

              // Store user data if available
              if (data['user'] != null) {
                final user = data['user'];
                if (user['id'] != null) {
                  await prefs.setInt('user_id', user['id']);
                }
                if (user['username'] != null) {
                  await prefs.setString('username', user['username'].toString());
                }
                if (user['email'] != null) {
                  await prefs.setString('email', user['email'].toString());
                }
              }

              print('Token refreshed successfully');
              _isRefreshing = false;
              return true;
            }
          } else {
            print('Token refresh failed: ${data['error']}');
          }
        } else {
          Map<String, dynamic>? errorData;
          try {
            errorData = json.decode(response.body);
          } catch (_) {}

          final errorMessage =
              errorData != null ? errorData['error']?.toString() : null;

          print('Token refresh failed (${response.statusCode}): $errorMessage');
          
          // If refresh token is expired OR explicitly invalidated, clear all tokens
          final isInvalidated = (errorMessage ?? '')
              .toLowerCase()
              .contains('token invalidated by password reset');
          
          // Permanent failures - don't retry
          if (response.statusCode == 401 ||
              response.statusCode == 400 ||
              isInvalidated) {
            print('Permanent auth failure. Clearing tokens.');
            await clearTokens();
            _isRefreshing = false;
            return false;
          }
          
          // Temporary server errors (500, 502, 503, 504) - retry
          if (response.statusCode >= 500 && response.statusCode < 600) {
            if (retryCount < maxRetries) {
              print('Server error (${response.statusCode}). Will retry...');
              retryCount++;
              continue; // Retry
            } else {
              print('Max retries reached for server error. Giving up.');
              _isRefreshing = false;
              return false;
            }
          }
          
          // Other errors - don't retry
          _isRefreshing = false;
          return false;
        }
      } catch (e) {
        print('Error refreshing token (attempt ${retryCount + 1}): $e');
        
        // Network errors - retry
        if (retryCount < maxRetries) {
          retryCount++;
          continue; // Retry
        } else {
          print('Max retries reached. Giving up.');
          _isRefreshing = false;
          return false;
        }
      }
    }

    _isRefreshing = false;
    return false;
  }

  /// Clear all tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyTokenExpiresAt);
    print('Tokens cleared');
  }

  /// Store tokens after login
  static Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);

    if (expiresAt != null) {
      await prefs.setInt(_keyTokenExpiresAt, expiresAt.millisecondsSinceEpoch);
    } else if (expiresIn != null) {
      final calculatedExpiresAt = DateTime.now().add(Duration(seconds: expiresIn));
      await prefs.setInt(_keyTokenExpiresAt, calculatedExpiresAt.millisecondsSinceEpoch);
    } else {
      // Default to 2 hours if not provided
      final defaultExpiresAt = DateTime.now().add(Duration(hours: 2));
      await prefs.setInt(_keyTokenExpiresAt, defaultExpiresAt.millisecondsSinceEpoch);
    }
  }

  /// Get token with auto-refresh if needed
  static Future<String?> getValidToken() async {
    // Check if token is expiring soon or expired
    if (await isTokenExpiringSoon(minutesBefore: 5) || await isTokenExpired()) {
      print('Token expired or expiring soon, refreshing...');
      final refreshed = await refreshToken();
      if (!refreshed) {
        return null;
      }
    }

    return await getAccessToken();
  }
}

