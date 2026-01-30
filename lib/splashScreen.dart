import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/const/color_const.dart';
import 'core/const/assets_const.dart';
import 'core/bloc/appBloc/appBloc.dart';
import 'core/bloc/appBloc/appEvent.dart';
import 'core/bloc/appBloc/appState.dart';
import 'core/bloc/userBloc/userBloc.dart';
import 'core/bloc/userBloc/userEvent.dart';
import 'core/bloc/layoutBloc/layoutBloc.dart';
import 'core/bloc/layoutBloc/layoutEvent.dart';
import 'core/bloc/notificationBloc/notificationBloc.dart';
import 'core/bloc/notificationBloc/notificationEvent.dart';
import 'core/auth/tokenManager.dart';
import 'core/auth/tokenRefreshService.dart';
import 'View/login/loginScreen.dart';

import 'main.dart';
import 'navigationPage.dart';

class SessionManager {
  static const _keyLoggedIn = 'isLoggedIn';
  static const _keySession = 'session';
  static const _keySessionID = 'sessionID';
  static const _keyUserID = 'userID';

  static Future<void> setSession({
    required String session,
    required int sessionID,
    required int userID,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keySession, session);
    await prefs.setInt(_keySessionID, sessionID);
    await prefs.setInt(_keyUserID, userID);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySession);
  }

  static Future<int?> getSessionID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySessionID);
  }

  static Future<int?> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserID);
  }

  static Future<void> logoutLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// TokenManager has been moved to core/auth/tokenManager.dart
// Using the new TokenManager from there

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  bool _hasInternet = true;
  bool _isCheckingConnection = true;

  Future<void> checkInternetConnection() async {
    try {
      final List<ConnectivityResult> connectivityResult = await Connectivity()
          .checkConnectivity();

      print('Connectivity Result: $connectivityResult');

      // Check if any result is not none or bluetooth
      final hasConnection = connectivityResult.any(
        (result) =>
            result != ConnectivityResult.none &&
            result != ConnectivityResult.bluetooth,
      );

      print('Has Internet: $hasConnection');

      setState(() {
        _hasInternet = hasConnection;
        _isCheckingConnection = false;
      });

      if (_hasInternet) {
        // Fetch settings if internet is available
        context.read<AppBloc>().add(FetchSettingsEvent());
        checkLoginStatus();
      } else {
        print('No internet connection - staying on splash screen');
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      // If there's an error checking connectivity, assume no internet
      setState(() {
        _hasInternet = false;
        _isCheckingConnection = false;
      });
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final username = prefs.getString('username');
    final password = prefs.getString('login_password');
    final roleId = prefs.getInt('role_id');

    print('Checking login status... $username $password $token');
    print('User ID: ${prefs.getInt('user_id') ?? ''}');
    print('Username: ${username ?? ''}');
    print('Role ID: $roleId');
    print('Token exists: ${token != null && token.isNotEmpty}');

    await Future.delayed(const Duration(seconds: 2));

    // Check role ID first - only allow distributor (2) and retailer (6)
    if (roleId != null && roleId != 2 && roleId != 6) {
      print('❌ Unauthorized role ID: $roleId. Logging out user...');
      // Clear all user data and tokens
      await TokenManager.clearTokens();
      await prefs.clear();
      // Navigate to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => loginScreen()),
        );
      }
      return;
    }

    if (token != null && token.isNotEmpty) {
      print('Token found, validating...');

      // Validate the token using new TokenManager
      final validationResult = await TokenManager.validateToken();

      // If validation failed due to a server error (e.g. 500) and we didn't get
      // a structured response, do NOT force logout. Assume the token is still
      // usable (other authenticated APIs work) and continue to home.
      if (validationResult == null) {
        print(
          'Token validation could not be completed (null response). Skipping strict validation and proceeding as logged-in.',
        );

        // Start token refresh service
        TokenRefreshService.start();

        try {
          context.read<UserBloc>().add(FetchUserDetailsEvent());
        } catch (_) {}
        try {
          print(
            '📰 [SPLASH] Dispatching FetchNewsEvent (validation null path)...',
          );
          context.read<AppBloc>().add(FetchNewsEvent());
          print(
            '📰 [SPLASH] FetchNewsEvent dispatched successfully (validation null path)',
          );
        } catch (e) {
          print(
            '⚠️ Error dispatching FetchNewsEvent (validation null path): $e',
          );
        }
        try {
          context.read<LayoutBloc>().add(FetchLayoutsEvent());
        } catch (e) {
          print(
            '⚠️ Error dispatching FetchLayoutsEvent (validation null path): $e',
          );
        }
        try {
          context.read<NotificationBloc>().add(
            const FetchNotificationStatsEvent(),
          );
        } catch (_) {}

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => navigationPage(initialIndex: 0)),
          );
        }
        return;
      }

      final isValid = validationResult['is_valid'] == true;
      final isExpired = validationResult['is_expired'] == true;
      final validationMessage = validationResult['message']?.toString();

      if (isValid) {
        // Double-check role ID after token validation
        final currentRoleId = prefs.getInt('role_id');
        if (currentRoleId != null && currentRoleId != 2 && currentRoleId != 6) {
          print(
            '❌ Unauthorized role ID after validation: $currentRoleId. Logging out...',
          );
          await TokenManager.clearTokens();
          await prefs.clear();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => loginScreen()),
            );
          }
          return;
        }
        // Start token refresh service
        TokenRefreshService.start();
        print(
          'Token is valid, dispatching refetch events and navigating to home',
        );
        // Ensure fresh data for this user before navigating
        try {
          context.read<UserBloc>().add(FetchUserDetailsEvent());
        } catch (_) {}
        // Banners are already loaded in main.dart on app startup, no need to refetch here
        // try {
        //   context.read<AppBloc>().add(FetchBannersEvent());
        // } catch (e) {
        //   print('⚠️ Error dispatching FetchBannersEvent: $e');
        // }
        try {
          print('📰 [SPLASH] Dispatching FetchNewsEvent...');
          context.read<AppBloc>().add(FetchNewsEvent());
          print('📰 [SPLASH] FetchNewsEvent dispatched successfully');
        } catch (e) {
          print('⚠️ Error dispatching FetchNewsEvent: $e');
        }
        try {
          context.read<LayoutBloc>().add(FetchLayoutsEvent());
        } catch (e) {
          print('⚠️ Error dispatching FetchLayoutsEvent: $e');
        }
        try {
          context.read<NotificationBloc>().add(
            const FetchNotificationStatsEvent(),
          );
        } catch (_) {}
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => navigationPage(initialIndex: 0)),
        );
      } else {
        // If backend tells us the token was invalidated due to password reset,
        // clear everything and send user to login.
        if (!isExpired &&
            validationMessage != null &&
            validationMessage.toLowerCase() ==
                'token invalidated by password reset') {
          print(
            'Token invalidated by password reset (splash). Clearing tokens and redirecting to login.',
          );
          await TokenManager.clearTokens();
          await prefs.clear();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => loginScreen(
                  logoutMessage: 'Your password was reset. Please login again.',
                ),
              ),
            );
          }
          return;
        }

        print('Token is invalid or expired, attempting to refresh...');

        // Try to refresh token using refresh token
        print('Attempting token refresh with refresh token');
        final refreshed = await TokenManager.refreshToken();

        if (refreshed) {
          print(
            'Token refresh successful, starting refresh service and navigating to home',
          );
          // Double-check role ID after token refresh
          final currentRoleId = prefs.getInt('role_id');
          if (currentRoleId != null &&
              currentRoleId != 2 &&
              currentRoleId != 6) {
            print(
              '❌ Unauthorized role ID after refresh: $currentRoleId. Logging out...',
            );
            await TokenManager.clearTokens();
            await prefs.clear();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => loginScreen()),
              );
            }
            return;
          }
          // Start token refresh service
          TokenRefreshService.start();
          try {
            context.read<UserBloc>().add(FetchUserDetailsEvent());
          } catch (_) {}
          // Banners are already loaded in main.dart on app startup, no need to refetch here
          // try {
          //   context.read<AppBloc>().add(FetchBannersEvent());
          // } catch (e) {
          //   print('⚠️ Error dispatching FetchBannersEvent (refresh): $e');
          // }
          try {
            print('📰 [SPLASH] Dispatching FetchNewsEvent (refresh path)...');
            context.read<AppBloc>().add(FetchNewsEvent());
            print(
              '📰 [SPLASH] FetchNewsEvent dispatched successfully (refresh path)',
            );
          } catch (e) {
            print('⚠️ Error dispatching FetchNewsEvent (refresh): $e');
          }
          try {
            context.read<LayoutBloc>().add(FetchLayoutsEvent());
          } catch (e) {
            print('⚠️ Error dispatching FetchLayoutsEvent (refresh): $e');
          }
          try {
            context.read<NotificationBloc>().add(
              const FetchNotificationStatsEvent(),
            );
          } catch (_) {}
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => navigationPage(initialIndex: 0)),
          );
        } else {
          print('Token refresh failed, redirecting to login');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => loginScreen()),
          );
        }
      }
    } else {
      print('No token found, navigating to login');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => loginScreen()),
      );
    }
  }

  Future<void> retryConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });
    await checkInternetConnection();
  }

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: colorConst.primaryColor1,
      backgroundColor: colorConst.lightBlue,
      // backgroundColor: colorConst.primaryColor3,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bgtask.png"),
              fit: BoxFit.cover,
              opacity: 0.06,
            ),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCheckingConnection)
                Column(
                  children: [
                    Container(height: 200),
                    SizedBox(height: scrWidth * 0.25),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                        child: LoadingAnimationWidget.progressiveDots(
                          size: 50,
                          color: colorConst.primaryColor1,
                        ),
                      ),
                    ),
                  ],
                )
              else if (!_hasInternet)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please check your internet connection and try again',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: retryConnection,
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorConst.primaryColor1,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    String logoPath = "assets/images/ybs.jpeg";
                    if (state is AppLoaded && state.settings?.logo != null) {
                      logoPath =
                          "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.width * 0.75,
                          child: logoPath.startsWith('http')
                              ? Image.network(
                                  logoPath,
                                  height: 200,
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox.shrink();
                                  },
                                )
                              : SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              if (_hasInternet && !_isCheckingConnection)
                Column(
                  children: [
                    SizedBox(height: scrWidth * 0.25),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                        child: LoadingAnimationWidget.progressiveDots(
                          size: 50,
                          color: colorConst.primaryColor1,
                        ),
                      ),
                    ),
                  ],
                ),
              //     :Container(
              //   width: MediaQuery.of(context).size.width*1,
              //   height: MediaQuery.of(context).size.width*0.3,
              //   child: InkWell(
              //       onTap: () {
              //         setState(() {
              //           showProgress=true;
              //         });
              //         // _checkMockLocation();
              //       },
              //       child: Icon(Icons.refresh,color: Colors.grey.shade300,size: 34,)),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
