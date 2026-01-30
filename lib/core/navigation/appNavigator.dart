import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/tokenManager.dart';
import '../auth/tokenRefreshService.dart';
import '../../View/login/loginScreen.dart';

/// Global navigator and logout helper for forcing app-wide logout
class AppNavigator {
  /// Navigator key used by [MaterialApp] in `main.dart`
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Convenience getter for current context (may be null)
  static BuildContext? get context => navigatorKey.currentContext;

  /// Force a full logout from anywhere in the app.
  ///
  /// - Clears all tokens and shared preferences
  /// - Stops the token refresh service
  /// - Navigates to the login screen, removing all previous routes
  /// - Optionally shows a logout message on the login screen
  static Future<void> forceLogout({String? message}) async {
    final ctx = context;
    if (ctx == null) {
      // If we don't have a context yet, just clear tokens; navigation will
      // be handled on next app entry via splashScreen.
      await TokenManager.clearTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      TokenRefreshService.stop();
      return;
    }

    // Clear auth/session data
    await TokenManager.clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    TokenRefreshService.stop();

    // Navigate to login and wipe back stack
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => loginScreen(
          logoutMessage: message ?? 'Your session has ended. Please login again.',
        ),
      ),
      (route) => false,
    );
  }
}

