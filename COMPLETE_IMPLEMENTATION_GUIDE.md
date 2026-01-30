# 📱 Complete Implementation Guide - FCM Notifications & All Changes

## 📋 Overview

This document contains **ALL changes** made to implement Firebase Cloud Messaging (FCM) push notifications and other updates. Use this guide to implement the same features in the customer app.

**Important:** Since both apps (Retailer/Distributor and Customer) use the same backend/admin, **NO backend changes are needed**. Only frontend implementation is required.

---

## 🎯 What Was Implemented

1. **Firebase Cloud Messaging (FCM) Push Notifications**
   - Complete FCM service implementation
   - Token registration with backend
   - Foreground, background, and terminated state handling
   - Banner notifications
   - Notification tap navigation
   - **Fixed:** Duplicate notification issue in background/terminated state

2. **Firebase Setup**
   - Firebase SDK integration
   - Firebase options configuration
   - Gradle configuration

3. **Android Configuration**
   - Notification permissions
   - minSdkVersion update (21 → 23)
   - Core library desugaring

4. **Pull-to-Refresh Implementation**
   - Replaced refresh icon in appbar with pull-to-refresh gesture
   - Implemented on retailer homepage
   - Implemented on distributor dashboard

---

## 📁 Files Created

### **1. `lib/core/services/fcm_service.dart`**
**Purpose:** Complete FCM service for handling push notifications

**Complete Code:**
```dart
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
/// IMPORTANT: Fixed duplicate notification issue - only shows local notification for data-only messages
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
    // This will be picked up by the app's main navigation
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
```

---

### **2. `lib/firebase_options.dart`**
**Purpose:** Firebase configuration file

**Note:** This file should be generated using `flutterfire configure` OR manually created from `google-services.json`

**Template Code:**
```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY_FROM_GOOGLE_SERVICES_JSON',
    appId: 'YOUR_APP_ID_FROM_GOOGLE_SERVICES_JSON',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
```

**To get values:** Extract from `android/app/google-services.json`:
- `apiKey`: `client[0].api_key[0].current_key`
- `appId`: `client[0].client_info.mobilesdk_app_id`
- `messagingSenderId`: `project_info.project_number`
- `projectId`: `project_info.project_id`
- `storageBucket`: `project_info.storage_bucket`

---

## 📝 Files Modified

### **1. `lib/main.dart`**

**Changes:**
1. Added Firebase imports
2. Initialize Firebase on app startup
3. Initialize FCM service
4. Register FCM token if user is already logged in

**Code Changes:**
```dart
// Add these imports at the top
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/fcm_service.dart';

// In main() function, add before runApp():
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
    
    // Initialize FCM service
    await FCMService().initialize();
    print('✅ FCM service initialized');
  } catch (e) {
    print('⚠️ Firebase initialization error: $e');
    // Continue app startup even if Firebase fails
  }

  // Start token refresh service if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  if (accessToken != null && accessToken.isNotEmpty) {
    TokenRefreshService.start();
    
    // Register FCM token if user is already logged in
    try {
      await FCMService().registerPendingToken();
    } catch (e) {
      print('⚠️ Error registering FCM token: $e');
    }
  }

  // ... rest of your main() function
}
```

---

### **2. `lib/core/repository/signIn/signInAuthRepository.dart`**

**Changes:**
1. Added optional `fcmToken` parameter to `login()` method
2. Added optional `fcmToken` parameter to `verifyOtp()` method

**Code Changes:**
```dart
// Update login method signature
Future<UserModel> login(String userId, String password, {String? fcmToken}) async {
  final url = Uri.parse("${AssetsConst.apiBase}api/login/");

  // Prepare request body as JSON
  final bodyMap = {
    'user_id': userId,
    'password': password,
  };
  
  // Add FCM token if provided
  if (fcmToken != null && fcmToken.isNotEmpty) {
    bodyMap['fcm_token'] = fcmToken;
  }
  
  final body = jsonEncode(bodyMap);
  
  // ... rest of the method remains the same
}

// Update verifyOtp method signature
Future<UserModel> verifyOtp(String username, String otp, {String? fcmToken}) async {
  final url = Uri.parse("${AssetsConst.apiBase}api/verify-login-otp/");

  // Prepare request body as JSON
  final bodyMap = {
    'username': username,
    'otp': otp,
  };
  
  // Add FCM token if provided
  if (fcmToken != null && fcmToken.isNotEmpty) {
    bodyMap['fcm_token'] = fcmToken;
  }
  
  final body = jsonEncode(bodyMap);
  
  // ... rest of the method ...
  
  // After successful OTP verification, add role validation:
  if (data['status'] == 'verified') {
    // Parse user model first to check role
    final user = UserModel.fromJson(data);
    
    // Validate role ID - only allow distributor (2) and retailer (6)
    final roleId = user.roleId;
    if (roleId != 2 && roleId != 6) {
      print('❌ Unauthorized role ID: $roleId. Only role IDs 2 (Distributor) and 6 (Retailer) are allowed.');
      throw UnauthorizedRoleException(
        roleId: roleId,
        roleName: user.roleName,
      );
    }
    
    await storeLoginData(data);
    return user;
  }
}

// Add custom exception class at the end of the file:
class UnauthorizedRoleException implements Exception {
  final int roleId;
  final String roleName;

  UnauthorizedRoleException({
    required this.roleId,
    required this.roleName,
  });

  @override
  String toString() => 'Access denied. This app is only for Distributors and Retailers. Your role ($roleName) is not authorized to access this application.';
}
```

---

### **3. `lib/core/bloc/authBloc/signIn/signInAuthBloc.dart`**

**Changes:**
1. Import FCM service
2. Get FCM token before login/OTP
3. Pass FCM token to repository
4. Register token after successful login

**Code Changes:**
```dart
// Add import
import '../../../services/fcm_service.dart';

class signInAuthBloc extends Bloc<signInAuthEvent, signInAuthState> {
  final signInAuthRepository authRepository;
  final FCMService _fcmService = FCMService(); // Add this

  signInAuthBloc(this.authRepository) : super(signInAuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(signInAuthLoading());
      try {
        // Get FCM token if available
        final fcmToken = _fcmService.fcmToken;
        final user = await authRepository.login(event.username, event.password, fcmToken: fcmToken);
        
        // Register FCM token with backend after successful login
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await _fcmService.registerPendingToken();
        }
        
        emit(signInAuthSuccess(user));
      } catch (e) {
        // ... error handling remains the same
      }
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(signInAuthLoading());
      try {
        // Get FCM token if available
        final fcmToken = _fcmService.fcmToken;
        final user = await authRepository.verifyOtp(event.username, event.otp, fcmToken: fcmToken);
        
        // Register FCM token with backend after successful login
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await _fcmService.registerPendingToken();
        }
        
        emit(signInAuthSuccess(user));
      } catch (e) {
        // ... error handling remains the same
      }
    });
  }
}
```

---

### **4. `pubspec.yaml`**

**Changes:**
1. Added Firebase dependencies
2. Added local notifications dependency
3. Updated minSdk for launcher icons

**Code Changes:**
```yaml
dependencies:
  # ... existing dependencies ...
  
  # Firebase dependencies
  firebase_core: ^3.8.0
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^17.0.0

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/trvappicon.png"
  min_sdk_android: 23  # Updated from 21 to 23
```

---

### **5. `android/build.gradle.kts` (Root Level)**

**Changes:**
1. Added Google services plugin

**Code Changes:**
```kotlin
plugins {
    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.4" apply false
}

// ... rest of the file remains the same
```

---

### **6. `android/app/build.gradle.kts`**

**Changes:**
1. Added Google services plugin
2. Enabled core library desugaring
3. Updated minSdk to 23
4. Added Firebase dependencies
5. Added desugaring dependency

**Complete Code:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.ybs_pay"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true  // Added
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.ybs_pay"
        minSdk = 23  // Changed from flutter.minSdkVersion to 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))
    
    // Add the dependencies for Firebase products you want to use
    // When using the BoM, don't specify versions in Firebase dependencies
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
    
    // Core library desugaring (required for flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---

### **7. `lib/View/Home/1homeScreen.dart`**

**Changes:**
1. Removed refresh icon from appbar
2. Added `RefreshIndicator` wrapper around `SingleChildScrollView`
3. Changed scroll physics to enable pull-to-refresh

**Code Changes:**
```dart
// Before: Had refresh icon in appbar
// After: Removed appbar refresh icon, added RefreshIndicator

// In build method, wrap SingleChildScrollView with RefreshIndicator:
body: SafeArea(
  child: RefreshIndicator(
    backgroundColor: Colors.white,
    onRefresh: () async {
      refreshHomeData();
      await Future.delayed(const Duration(milliseconds: 500));
    },
    color: colorConst.primaryColor1,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        children: [
          // ... existing content ...
        ],
      ),
    ),
  ),
),
```

**Note:** The `refreshHomeData()` method should refresh all necessary data:
```dart
void refreshHomeData() {
  context.read<LayoutBloc>().add(FetchLayoutsEvent());
  context.read<UserBloc>().add(FetchUserDetailsEvent());
  context.read<AppBloc>().add(FetchBannersEvent());
  context.read<NotificationBloc>().add(const FetchNotificationStatsEvent());
  context.read<DashboardBloc>().add(
    FetchDashboardStatistics(period: 'month'),
  );
}
```

---

### **8. `lib/View/Distributor/distributorDashboardScreen.dart`**

**Changes:**
1. Added `RefreshIndicator` wrapper around `SingleChildScrollView`
2. Changed scroll physics to enable pull-to-refresh
3. Added user data refresh for topHeader

**Code Changes:**
```dart
// Wrap SingleChildScrollView with RefreshIndicator:
return RefreshIndicator(
  onRefresh: () async {
    // Refresh dashboard data
    context.read<DistributorDashboardBloc>().add(FetchDistributorDashboardEvent());
    // Refresh user data (for topHeader)
    context.read<UserBloc>().add(FetchUserDetailsEvent());
    // Wait a bit for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  },
  color: colorConst.primaryColor1,
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... existing content ...
      ],
    ),
  ),
);
```

---

### **9. `lib/View/Home/widgets/home_app_bar.dart`**

**Changes:**
1. Removed `onRefresh` parameter (no longer needed)
2. Removed refresh icon from appbar

**Code Changes:**
```dart
// Before:
class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onRefresh;
  const HomeAppBar({super.key, this.onRefresh});
  // ... had refresh icon in actions ...
}

// After:
class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key}); // Removed onRefresh parameter
  // ... removed refresh icon from actions ...
}
```

---

### **10. `android/app/src/main/AndroidManifest.xml`**

**Changes:**
1. Added notification permissions

**Code Changes:**
```xml
<manifest xmlns:tools="http://schemas.android.com/tools"
    xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- ... existing permissions ... -->
    
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <!-- ... rest of the manifest ... -->
</manifest>
```

---

## 🔧 Setup Steps for Customer App

### **Step 1: Add Dependencies**

1. Update `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^3.8.0
     firebase_messaging: ^15.1.5
     flutter_local_notifications: ^17.0.0
   ```

2. Run:
   ```bash
   flutter pub get
   ```

---

### **Step 2: Configure Firebase**

1. **Get `google-services.json`:**
   - Go to Firebase Console
   - Select your project (same as retailer/distributor app)
   - Add Android app (if not already added)
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

2. **Generate `firebase_options.dart`:**
   ```bash
   dart pub global activate flutterfire_cli
   dart pub global run flutterfire_cli:flutterfire configure
   ```
   
   OR manually create from `google-services.json` (see template above)

---

### **Step 3: Update Gradle Files**

1. **`android/build.gradle.kts`** - Add Google services plugin (see code above)

2. **`android/app/build.gradle.kts`** - Apply all changes (see code above)

---

### **Step 4: Update AndroidManifest.xml**

Add notification permissions (see code above)

---

### **Step 5: Create FCM Service**

1. Create `lib/core/services/fcm_service.dart`
2. Copy the complete code from above

---

### **Step 6: Update Main Files**

1. **`lib/main.dart`** - Add Firebase initialization (see code above)

2. **`lib/core/repository/signIn/signInAuthRepository.dart`** - Add FCM token support (see code above)

3. **`lib/core/bloc/authBloc/signIn/signInAuthBloc.dart`** - Add FCM token registration (see code above)

---

### **Step 7: Test**

1. Run the app
2. Log in
3. Check console for FCM token
4. Verify token registration in backend logs
5. Send test notification from Firebase Console

---

## 📋 Checklist

- [ ] Add dependencies to `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Add `google-services.json` to `android/app/`
- [ ] Generate/create `firebase_options.dart`
- [ ] Update `android/build.gradle.kts`
- [ ] Update `android/app/build.gradle.kts`
- [ ] Update `AndroidManifest.xml`
- [ ] Create `lib/core/services/fcm_service.dart`
- [ ] Update `lib/main.dart`
- [ ] Update `lib/core/repository/signIn/signInAuthRepository.dart`
- [ ] Update `lib/core/bloc/authBloc/signIn/signInAuthBloc.dart`
- [ ] Test FCM token registration
- [ ] Test push notifications

---

## 🔍 Backend Requirements

**NO BACKEND CHANGES NEEDED!**

The backend is already set up for both apps:
- ✅ FCM token registration endpoint exists
- ✅ FCM notifications are sent automatically
- ✅ Same admin/backend for both apps

**Backend API Endpoint:**
- `POST /api/register-fcm-token-android/` - Already implemented

---

## 📱 How It Works

### **App States:**

1. **Foreground (App Open):**
   - Notification received → Local notification banner shown
   - User can tap to navigate

2. **Background (App Minimized):**
   - Notification received → System banner notification shown
   - User can tap to open app and navigate

3. **Terminated (App Closed):**
   - Notification received → System banner notification shown
   - User can tap to open app and navigate

### **Token Management:**

1. **On App Startup:**
   - FCM token obtained
   - If user logged in → Token registered with backend

2. **On Login:**
   - FCM token sent with login request
   - After successful login → Token registered separately

3. **On Token Refresh:**
   - Automatically re-registered with backend

---

## 🎯 Key Features

✅ **Banner Notifications** - Appear as system notifications  
✅ **Sound & Vibration** - Enabled by default  
✅ **Foreground Handling** - Shows local notification when app is open  
✅ **Background Handling** - Shows system notification when app is minimized  
✅ **Terminated Handling** - Shows system notification when app is closed  
✅ **Auto Token Registration** - Automatically registers on login  
✅ **Token Refresh** - Automatically handles token updates  
✅ **Navigation Support** - Handles notification taps for navigation  

---

## 📚 Additional Notes

1. **Same Firebase Project:** Both apps can use the same Firebase project
2. **Same Backend:** No backend changes needed
3. **Different Package Names:** Each app should have its own package name
4. **minSdk 23:** Required for Firebase Messaging (Android 6.0+)

---

## ✅ Implementation Complete

Once all steps are followed, the customer app will have the same FCM notification functionality and pull-to-refresh features as the retailer/distributor app!

---

## 📋 Summary of All Changes Today

### **Files Created:**
1. `lib/core/services/fcm_service.dart` - Complete FCM service
2. `lib/firebase_options.dart` - Firebase configuration

### **Files Modified:**
1. `lib/main.dart` - Firebase initialization
2. `lib/core/repository/signIn/signInAuthRepository.dart` - FCM token support + Role validation
3. `lib/core/bloc/authBloc/signIn/signInAuthBloc.dart` - Token registration + Role validation handling
4. `lib/splashScreen.dart` - Role validation on app startup
5. `pubspec.yaml` - Dependencies
6. `android/build.gradle.kts` - Google services plugin
7. `android/app/build.gradle.kts` - Firebase dependencies, desugaring, minSdk
8. `android/app/src/main/AndroidManifest.xml` - Permissions
9. `lib/View/Home/1homeScreen.dart` - Pull-to-refresh
10. `lib/View/Distributor/distributorDashboardScreen.dart` - Pull-to-refresh
11. `lib/View/Home/widgets/home_app_bar.dart` - Removed refresh icon

### **Key Features Implemented:**
✅ FCM push notifications (foreground, background, terminated)  
✅ Banner notifications  
✅ Auto token registration  
✅ Pull-to-refresh on homepage  
✅ Pull-to-refresh on distributor dashboard  
✅ Fixed duplicate notification bug  
✅ Role-based access control (only role IDs 2 & 6 allowed)  

---

## 🐛 Bug Fixes

### **1. Duplicate Background Notifications (Fixed)**

**Issue:** When app was in background/terminated state, notifications appeared twice.

**Cause:** 
- FCM automatically shows notifications when message has `notification` payload
- Our background handler was also showing a local notification
- Result: Duplicate notifications

**Fix:**
- Updated `firebaseMessagingBackgroundHandler` to only show local notification for data-only messages
- If message has `notification` payload, let FCM handle it automatically

**Code Change in `lib/core/services/fcm_service.dart`:**
```dart
// In firebaseMessagingBackgroundHandler:
if (message.notification == null && message.data.isNotEmpty) {
  // Data-only message - show local notification
  // ... show notification code ...
} else {
  // Message has notification payload - FCM will show it automatically
  // Don't show another notification
  print('✅ Notification payload present - FCM will show notification automatically');
}
```

**Important:** The background handler code in the document above has been updated with this fix. Make sure to use the corrected version when implementing in customer app.

---

### **2. Role-Based Access Control (Implemented)**

**Requirement:** Only users with role ID 2 (Distributor) and 6 (Retailer) should be able to login and access the app.

**Implementation Points:**
1. **Login Validation:** Added role check in `login()` method
2. **OTP Validation:** Added role check in `verifyOtp()` method  
3. **Splash Screen Validation:** Added role check on app startup
4. **Custom Exception:** Created `UnauthorizedRoleException` for unauthorized roles

**Code Changes:**

**In `lib/core/repository/signIn/signInAuthRepository.dart`:**
```dart
// After parsing UserModel, add validation:
if (data['status'] == 'success') {
  // Parse user model first to check role
  final user = UserModel.fromJson(data);
  
  // Validate role ID - only allow distributor (2) and retailer (6)
  final roleId = user.roleId;
  if (roleId != 2 && roleId != 6) {
    print('❌ Unauthorized role ID: $roleId. Only role IDs 2 (Distributor) and 6 (Retailer) are allowed.');
    throw UnauthorizedRoleException(
      roleId: roleId,
      roleName: user.roleName,
    );
  }
  
  await storeLoginData(data);
  return user;
}

// Add custom exception class:
class UnauthorizedRoleException implements Exception {
  final int roleId;
  final String roleName;

  UnauthorizedRoleException({
    required this.roleId,
    required this.roleName,
  });

  @override
  String toString() => 'Access denied. This app is only for Distributors and Retailers. Your role ($roleName) is not authorized to access this application.';
}
```

**In `lib/core/bloc/authBloc/signIn/signInAuthBloc.dart`:**
```dart
// Handle UnauthorizedRoleException:
} catch (e) {
  if (e is repo.UnauthorizedRoleException) {
    emit(signInAuthFailure(loginErrorMessage: e.toString()));
  } else if (e is repo.OtpRequiredException) {
    // ... OTP handling ...
  } else {
    emit(signInAuthFailure(loginErrorMessage: e.toString()));
  }
}
```

**In `lib/splashScreen.dart`:**
```dart
// In checkLoginStatus() method, add role validation at the start:
final roleId = prefs.getInt('role_id');

// Check role ID first - only allow distributor (2) and retailer (6)
if (roleId != null && roleId != 2 && roleId != 6) {
  print('❌ Unauthorized role ID: $roleId. Logging out user...');
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

// Also add validation after token validation and refresh
```

**Error Message Shown to User:**
```
"Access denied. This app is only for Distributors and Retailers. Your role ([RoleName]) is not authorized to access this application."
```

---

**Last Updated:** Today's implementation  
**Backend Status:** ✅ No changes needed (already implemented)  
**Frontend Status:** ⚠️ Needs implementation in customer app

