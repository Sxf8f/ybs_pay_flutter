import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

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

class TokenManager {
  static Future<bool> validateToken(String token) async {
    try {
      print('Validating token: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('${AssetsConst.apiBase}api/validate-token-android/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      print('Token validation response status: ${response.statusCode}');
      print('Token validation response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isValid = data['is_valid'] ?? false;
        final isExpired = data['is_expired'] ?? true;

        print('Token validation result - Valid: $isValid, Expired: $isExpired');

        return isValid && !isExpired;
      }

      return false;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  static Future<String?> refreshToken(String username, String password) async {
    try {
      print('Refreshing token for username: $username');

      final response = await http.post(
        Uri.parse('${AssetsConst.apiBase}api/refresh-token-android/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Token refresh response status: ${response.statusCode}');
      print('Token refresh response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] ?? false;

        if (success) {
          final newToken = data['token'];
          final user = data['user'];

          print('Token refresh successful');
          print('New token: ${newToken.substring(0, 20)}...');
          print('User data: $user');

          // Store the new token and user data
          await _storeRefreshedToken(newToken, user);

          return newToken;
        }
      }

      print('Token refresh failed');
      return null;
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  static Future<void> _storeRefreshedToken(
    String token,
    Map<String, dynamic> user,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Store the new token
    await prefs.setString('access_token', token);

    // Store updated user data if available
    await prefs.setInt('user_id', user['id'] ?? 0);
    await prefs.setString('username', user['username'] ?? '');
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('phone_number', user['phone_number'] ?? '');

    print('Refreshed token and user data stored successfully');
  }
}

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

    print('Checking login status... $username $password $token');
    print('User ID: ${prefs.getInt('user_id') ?? ''}');
    print('Username: ${username ?? ''}');
    print('Token exists: ${token != null && token.isNotEmpty}');

    await Future.delayed(const Duration(seconds: 2));

    if (token != null && token.isNotEmpty) {
      print('Token found, validating...');

      // Validate the token
      final isValid = await TokenManager.validateToken(token);

      if (isValid) {
        print(
          'Token is valid, dispatching refetch events and navigating to home',
        );
        // Ensure fresh data for this user before navigating
        try {
          context.read<UserBloc>().add(FetchUserDetailsEvent());
        } catch (_) {}
        try {
          context.read<AppBloc>().add(FetchBannersEvent());
        } catch (_) {}
        try {
          context.read<LayoutBloc>().add(FetchLayoutsEvent());
        } catch (_) {}
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
        print('Token is invalid or expired, attempting to refresh...');

        // Try to refresh token if we have stored credentials
        if (username != null &&
            username.isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          print('Attempting token refresh with stored credentials');
          final newToken = await TokenManager.refreshToken(username, password);

          if (newToken != null && newToken.isNotEmpty) {
            print(
              'Token refresh successful, dispatching refetch events and navigating to home',
            );
            try {
              context.read<UserBloc>().add(FetchUserDetailsEvent());
            } catch (_) {}
            try {
              context.read<AppBloc>().add(FetchBannersEvent());
            } catch (_) {}
            try {
              context.read<LayoutBloc>().add(FetchLayoutsEvent());
            } catch (_) {}
            try {
              context.read<NotificationBloc>().add(
                const FetchNotificationStatsEvent(),
              );
            } catch (_) {}
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => navigationPage(initialIndex: 0),
              ),
            );
          } else {
            print('Token refresh failed, navigating to login');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => loginScreen()),
            );
          }
        } else {
          print('No stored credentials for token refresh, navigating to login');
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
