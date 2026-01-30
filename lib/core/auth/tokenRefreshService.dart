import 'dart:async';
import 'tokenManager.dart';
import '../navigation/appNavigator.dart';

/// Service to proactively refresh tokens before they expire
class TokenRefreshService {
  static Timer? _refreshTimer;
  static bool _isRunning = false;

  /// Start the token refresh service
  /// Checks token validity every [checkIntervalMinutes] minutes
  /// Refreshes token [refreshBeforeMinutes] minutes before expiration
  static void start({
    int checkIntervalMinutes = 5,
    int refreshBeforeMinutes = 5,
  }) {
    if (_isRunning) {
      print('Token refresh service already running');
      return;
    }

    _isRunning = true;
    print('Starting token refresh service (check every $checkIntervalMinutes minutes)');

    // Check immediately
    _checkAndRefresh(refreshBeforeMinutes);

    // Then check periodically
    _refreshTimer = Timer.periodic(
      Duration(minutes: checkIntervalMinutes),
      (_) => _checkAndRefresh(refreshBeforeMinutes),
    );
  }

  /// Stop the token refresh service
  static void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isRunning = false;
    print('Token refresh service stopped');
  }

  /// Check if token needs refresh and refresh if needed
  static Future<void> _checkAndRefresh(int refreshBeforeMinutes) async {
    try {
      // First, validate the token with backend – this catches password-reset invalidation.
      final validation = await TokenManager.validateToken();
      final isValid = validation != null && (validation['is_valid'] == true);
      final isExpired =
          validation != null && (validation['is_expired'] == true);
      final message =
          validation != null ? validation['message']?.toString() : null;

      if (!isValid &&
          !isExpired &&
          message != null &&
          message.toLowerCase() == 'token invalidated by password reset') {
        // Password reset invalidation: force full logout & navigation.
        print(
            'Token invalidated by password reset (periodic check). Forcing global logout.');
        await AppNavigator.forceLogout(
          message: 'Your password was reset. Please login again.',
        );
        return;
      }

      // If token is expired or expiring soon, attempt refresh.
      final isExpiringSoon = await TokenManager.isTokenExpiringSoon(
        minutesBefore: refreshBeforeMinutes,
      );

      if (isExpired || isExpiringSoon) {
        print('Token expired or expiring soon, refreshing...');
        final refreshed = await TokenManager.refreshToken();
        if (refreshed) {
          print('Token refreshed successfully');
        } else {
          print('Token refresh failed');
        }
      } else {
        print('Token is still valid, no refresh needed');
      }
    } catch (e) {
      print('Error in token refresh service: $e');
    }
  }

  /// Check if service is running
  static bool get isRunning => _isRunning;
}

