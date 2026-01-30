import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/assets_const.dart';
import '../auth/httpClient.dart';
import 'dart:convert';

/// Top-level function to handle background messages
/// This runs when app is in background or terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Background message received: ${message.messageId}');
  print('📨 Title: ${message.notification?.title}');
  print('📨 Body: ${message.notification?.body}');
  print('📨 Data: ${message.data}');
  
  // IMPORTANT: If message has a notification payload, FCM automatically shows it
  // We should NOT show another notification to avoid duplicates
  // Only show local notification for data-only messages (no notification payload)
  
  if (message.notification == null && message.data.isNotEmpty) {
    // Data-only message - we need to show notification manually
    print('📨 Data-only message detected, showing local notification...');
    
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    
    await localNotifications.initialize(initSettings);
    
    // Create notification channel if not exists
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'notification_channel',
      'Notifications',
      description: 'App notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // Extract title and body from data if available
    final title = message.data['title'] ?? message.data['notification_title'] ?? 'Notification';
    final body = message.data['body'] ?? message.data['notification_body'] ?? message.data['message'] ?? 'New notification';
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'notification_channel',
      'Notifications',
      channelDescription: 'App notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );
    
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
    
    await localNotifications.show(
      message.hashCode,
      title.toString(),
      body.toString(),
      notificationDetails,
      payload: jsonEncode(message.data),
    );
    
    print('✅ Local notification shown for data-only message');
  } else {
    // Message has notification payload - FCM will show it automatically
    // We just log it, no need to show another notification
    print('✅ Notification payload present - FCM will show notification automatically');
  }
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _initialized = false;

  /// Initialize FCM service
  Future<void> initialize() async {
    if (_initialized) {
      print('⚠️ FCM already initialized');
      return;
    }

    try {
      print('🚀 Initializing FCM service...');

      // Request notification permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permissions granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Notification permissions granted provisionally');
      } else {
        print('❌ Notification permissions denied');
        return;
      }

      // Initialize local notifications for foreground notifications
      await _initializeLocalNotifications();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $_fcmToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _registerTokenWithBackend(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps (when app is in background or terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification (terminated state)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 App opened from terminated state via notification');
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      print('✅ FCM service initialized successfully');
    } catch (e) {
      print('❌ Error initializing FCM: $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📬 Local notification tapped: ${response.payload}');
        if (response.payload != null) {
          _handleNotificationNavigation(response.payload!);
        }
      },
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'notification_channel',
      'Notifications',
      description: 'App notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Foreground message received:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        data: message.data,
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped:');
    print('   Title: ${message.notification?.title}');
    print('   Data: ${message.data}');

    // Extract navigation data
    final data = message.data;
    if (data.containsKey('redirect_url') && data['redirect_url'] != null) {
      _handleNotificationNavigation(data['redirect_url'] as String);
    } else if (data.containsKey('type')) {
      // Handle different notification types
      final type = data['type'] as String;
      if (type == 'notification' && data.containsKey('notification_id')) {
        // Navigate to notification screen
        _handleNotificationNavigation('/notifications');
      } else if (type == 'payment' || type == 'wallet') {
        // Navigate to home or transaction screen
        _handleNotificationNavigation('/home');
      }
    }
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(String route) {
    // Store navigation route to be handled by app
    // This will be picked up by the app's navigation system
    print('🧭 Navigating to: $route');
    // Note: Actual navigation will be handled by the app's main navigation
    // You can use a global navigator key or event bus here
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'notification_channel',
      'Notifications',
      channelDescription: 'App notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Register FCM token with backend
  Future<bool> registerTokenWithBackend() async {
    if (_fcmToken == null || _fcmToken!.isEmpty) {
      print('⚠️ FCM token not available');
      return false;
    }

    return await _registerTokenWithBackend(_fcmToken!);
  }

  /// Internal method to register token
  Future<bool> _registerTokenWithBackend(String token) async {
    try {
      print('📤 Registering FCM token with backend...');

      // Check if user is logged in
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ User not logged in, skipping token registration');
        // Store token to register later after login
        await prefs.setString('pending_fcm_token', token);
        return false;
      }

      final url = Uri.parse('${AssetsConst.apiBase}api/register-fcm-token-android/');

      final response = await AuthenticatedHttpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type': 'android',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ FCM token registered successfully');
          // Clear pending token if exists
          await prefs.remove('pending_fcm_token');
          return true;
        } else {
          print('❌ Token registration failed: ${data['error']}');
          return false;
        }
      } else {
        print('❌ Token registration failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error registering FCM token: $e');
      // Store token to register later
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_fcm_token', token);
      return false;
    }
  }

  /// Register pending FCM token after login
  Future<void> registerPendingToken() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingToken = prefs.getString('pending_fcm_token');

    if (pendingToken != null && pendingToken.isNotEmpty) {
      print('📤 Registering pending FCM token after login...');
      final success = await _registerTokenWithBackend(pendingToken);
      if (success) {
        await prefs.remove('pending_fcm_token');
      }
    }

    // Also register current token if available
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      await _registerTokenWithBackend(_fcmToken!);
    }
  }

  /// Unregister FCM token (on logout)
  Future<void> unregisterToken() async {
    try {
      print('🗑️ Unregistering FCM token...');
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ User not logged in, skipping token unregistration');
        return;
      }

      final url = Uri.parse('${AssetsConst.apiBase}api/register-fcm-token-android/');

      // Send empty token or delete request (adjust based on backend API)
      final response = await AuthenticatedHttpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': '',
          'device_type': 'android',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token unregistered successfully');
      } else {
        print('⚠️ Token unregistration response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error unregistering FCM token: $e');
    }
  }
}

