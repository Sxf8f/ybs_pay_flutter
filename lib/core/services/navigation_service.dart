import 'package:flutter/material.dart';
import '../../View/login/loginScreen.dart';
import '../auth/tokenRefreshService.dart';

class NavigationService {
  static BuildContext? _rootContext;

  static void setRootContext(BuildContext context) {
    _rootContext = context;
  }

  static void logoutToLogin() {
    final context = _rootContext;
    if (context == null) {
      return;
    }

    TokenRefreshService.stop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => loginScreen()),
      (route) => false,
    );
  }
}
