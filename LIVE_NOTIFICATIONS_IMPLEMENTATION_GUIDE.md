# 🔔 Live/Background Notifications Implementation Guide

## 📋 Overview

To implement live/background notifications in your Flutter app, you need to set up **Firebase Cloud Messaging (FCM)** for push notifications. This allows notifications to be delivered even when the app is closed or in the background.

---

## 🎯 What's Needed

### **Current Status:**
✅ Firebase packages already added (`firebase_core`, `firebase_messaging`)
❌ FCM not yet configured
❌ No background message handlers
❌ No FCM token registration

---

## 🔧 Implementation Methods

### **Method 1: Firebase Cloud Messaging (FCM) - RECOMMENDED** ⭐

**Best for:** Push notifications when app is closed or in background

**How it works:**
1. Backend sends notification via FCM
2. FCM delivers to device
3. App receives notification even when closed
4. User taps notification → Opens app → Navigates to specific screen

**Pros:**
- ✅ Works when app is closed
- ✅ Works in background
- ✅ Works in foreground
- ✅ Battery efficient
- ✅ Reliable delivery

**Cons:**
- ⚠️ Requires Firebase setup
- ⚠️ Requires backend FCM integration

---

### **Method 2: WebSocket/Server-Sent Events (SSE)**

**Best for:** Real-time updates when app is open

**How it works:**
1. App opens WebSocket connection to backend
2. Backend sends notifications in real-time
3. App receives and displays immediately

**Pros:**
- ✅ Instant delivery
- ✅ Real-time updates
- ✅ No polling needed

**Cons:**
- ❌ Only works when app is open
- ❌ Battery drain (keeps connection open)
- ❌ More complex backend setup

---

### **Method 3: Polling (Current Method)**

**Best for:** Simple implementation, app open only

**How it works:**
1. App periodically checks for new notifications
2. Updates UI when new notifications found

**Pros:**
- ✅ Simple to implement
- ✅ Works with existing API

**Cons:**
- ❌ Only works when app is open
- ❌ Battery drain (constant polling)
- ❌ Not real-time (delayed)

---

## 🏗️ Recommended Approach: FCM + Polling Hybrid

**Best of both worlds:**
- **FCM** for background/closed app notifications
- **Polling** for foreground updates (when app is open)

---

## 📱 Frontend Implementation Steps

### **Step 1: Firebase Setup**

1. **Create Firebase Project** (if not already done)
   - Go to https://console.firebase.google.com/
   - Create new project or use existing
   - Add Android app with package name: `com.example.ybs_pay`

2. **Download `google-services.json`**
   - Place in `android/app/` directory

3. **Update `android/build.gradle`**
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

4. **Update `android/app/build.gradle`**
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

---

### **Step 2: Initialize Firebase in Flutter**

**File:** `lib/main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Will be generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

**Generate Firebase Options:**
```bash
flutter pub add firebase_core
flutter pub add firebase_messaging
flutterfire configure
```

---

### **Step 3: Request Permissions**

**File:** `lib/core/services/fcm_service.dart` (NEW FILE)

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Request notification permissions
  static Future<bool> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
  
  // Get FCM token
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
  
  // Initialize local notifications
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }
  
  // Background message handler (must be top-level function)
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    print('Background message received: ${message.messageId}');
    // Handle background notification
  }
  
  // Foreground message handler
  static void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.messageId}');
      // Show local notification
      _showLocalNotification(message);
    });
  }
  
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'notification_channel',
      'Notifications',
      channelDescription: 'App notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }
}
```

---

### **Step 4: Register FCM Token with Backend**

**File:** `lib/core/repository/notificationRepository/notificationRepo.dart`

```dart
// Add this method
Future<void> registerFCMToken(String fcmToken) async {
  final response = await AuthenticatedHttpClient.post(
    Uri.parse('${AssetsConst.apiBase}api/register-fcm-token-android/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: {
      'fcm_token': fcmToken,
      'device_type': 'android',
    },
  );

  if (response.statusCode == 200) {
    print('✅ FCM token registered successfully');
  } else {
    print('❌ Failed to register FCM token: ${response.statusCode}');
  }
}
```

---

### **Step 5: Initialize FCM on App Start**

**File:** `lib/main.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_service.dart';

// Top-level function for background messages (MUST be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FCMService.backgroundMessageHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize FCM
  await FCMService.initializeLocalNotifications();
  await FCMService.requestPermission();
  FCMService.setupForegroundHandler();
  
  // Get and register FCM token
  String? token = await FCMService.getToken();
  if (token != null) {
    print('FCM Token: $token');
    // Register with backend (after user login)
  }
  
  runApp(MyApp());
}
```

---

### **Step 6: Handle Notification Taps**

**File:** `lib/main.dart` or `lib/core/services/fcm_service.dart`

```dart
// Handle notification tap when app is opened from notification
FirebaseMessaging.instance.getInitialMessage().then((message) {
  if (message != null) {
    _handleNotificationTap(message);
  }
});

// Handle notification tap when app is in background
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  _handleNotificationTap(message);
});

void _handleNotificationTap(RemoteMessage message) {
  // Navigate to notification screen or specific screen based on data
  final data = message.data;
  if (data['type'] == 'notification') {
    // Navigate to notification screen
  } else if (data['type'] == 'payment') {
    // Navigate to payment screen
  }
  // etc.
}
```

---

## 🔙 Backend Requirements

### **1. Register FCM Token Endpoint**

**New API Endpoint:** `POST /api/register-fcm-token-android/`

**Request Body:**
```json
{
  "fcm_token": "fcm_token_from_device",
  "device_type": "android"
}
```

**Backend Action:**
- Store FCM token linked to user ID
- Update token if user logs in on different device
- Remove token when user logs out

---

### **2. Send Push Notification**

**Backend Implementation (Python/Django example):**

```python
from firebase_admin import messaging
from firebase_admin import credentials
import firebase_admin

# Initialize Firebase Admin SDK (one-time setup)
cred = credentials.Certificate("path/to/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

def send_push_notification(user_id, title, body, data=None):
    # Get FCM token for user
    fcm_token = get_user_fcm_token(user_id)
    
    if not fcm_token:
        return False
    
    # Create message
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},  # Custom data payload
        token=fcm_token,
    )
    
    # Send message
    try:
        response = messaging.send(message)
        print(f'Successfully sent message: {response}')
        return True
    except Exception as e:
        print(f'Error sending message: {e}')
        return False
```

---

### **3. When to Send Notifications**

Backend should send FCM notifications when:
- ✅ New notification is created for user
- ✅ Payment status changes
- ✅ Wallet balance updated
- ✅ Transaction completed
- ✅ Any important event occurs

**Example:**
```python
# When creating a notification
def create_notification(user_id, title, message):
    # Save notification to database
    notification = Notification.objects.create(
        user_id=user_id,
        title=title,
        message=message,
    )
    
    # Send push notification
    send_push_notification(
        user_id=user_id,
        title=title,
        body=message,
        data={
            'type': 'notification',
            'notification_id': notification.id,
        }
    )
```

---

## 📦 Required Dependencies

**Already in `pubspec.yaml`:**
```yaml
firebase_core: ^3.8.0
firebase_messaging: ^15.1.5
```

**Need to add:**
```yaml
flutter_local_notifications: ^17.0.0  # For showing notifications
```

---

## 🔄 Integration with Existing Notification System

### **Current Flow:**
1. User opens notification screen → Fetches notifications via API
2. Notifications displayed from database

### **New Flow with FCM:**
1. **Backend creates notification** → Saves to database → Sends FCM push
2. **App receives FCM** → Shows notification → Updates badge count
3. **User taps notification** → Opens app → Navigates to notification screen
4. **Notification screen** → Fetches from API (same as before)

**No changes needed to existing notification APIs!** FCM is just for delivery.

---

## 🎯 Implementation Checklist

### **Frontend:**
- [ ] Generate `firebase_options.dart` using `flutterfire configure`
- [ ] Add `google-services.json` to `android/app/`
- [ ] Update `android/build.gradle` and `android/app/build.gradle`
- [ ] Create `FCMService` class
- [ ] Initialize FCM in `main.dart`
- [ ] Request permissions on app start
- [ ] Register FCM token with backend after login
- [ ] Handle foreground notifications
- [ ] Handle background notifications
- [ ] Handle notification taps (deep linking)
- [ ] Update notification badge when FCM received

### **Backend:**
- [ ] Install Firebase Admin SDK
- [ ] Initialize Firebase Admin SDK
- [ ] Create `POST /api/register-fcm-token-android/` endpoint
- [ ] Store FCM tokens linked to user IDs
- [ ] Send FCM notification when creating notifications
- [ ] Handle token updates (user logs in on new device)
- [ ] Handle token removal (user logs out)

---

## 📝 Summary

### **What You Need:**

1. **Firebase Project Setup**
   - Create Firebase project
   - Add Android app
   - Download `google-services.json`

2. **Backend Changes**
   - Add FCM token registration endpoint
   - Integrate Firebase Admin SDK
   - Send FCM when creating notifications

3. **Frontend Changes**
   - Initialize Firebase
   - Request permissions
   - Register FCM token
   - Handle incoming notifications
   - Handle notification taps

### **Existing APIs:**
✅ **No changes needed** - Your existing notification APIs work as-is. FCM is just for delivery.

### **Methods Available:**
1. **FCM** (Recommended) - Push notifications
2. **WebSocket** - Real-time when app open
3. **Polling** - Current method (keep for foreground)

---

## 🚀 Next Steps

1. Set up Firebase project
2. Configure Android app
3. Implement FCM service
4. Add backend FCM token registration
5. Integrate FCM sending in notification creation

Would you like me to start implementing the FCM service and integration?

