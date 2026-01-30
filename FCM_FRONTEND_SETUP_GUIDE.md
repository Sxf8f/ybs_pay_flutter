# 🔔 FCM Frontend Setup Guide

## ✅ Implementation Complete

The FCM (Firebase Cloud Messaging) frontend implementation is complete! Here's what has been done:

### **Files Created/Modified:**

1. ✅ **`lib/core/services/fcm_service.dart`** - Complete FCM service
2. ✅ **`lib/core/repository/signIn/signInAuthRepository.dart`** - Updated to include FCM token
3. ✅ **`lib/core/bloc/authBloc/signIn/signInAuthBloc.dart`** - Updated to register FCM token on login
4. ✅ **`lib/main.dart`** - FCM initialization on app startup
5. ✅ **`android/app/src/main/AndroidManifest.xml`** - Added notification permissions

---

## 🚀 Final Step: Generate Firebase Options

You need to generate `firebase_options.dart` file. This file contains your Firebase project configuration.

### **Option 1: Using FlutterFire CLI (Recommended)**

1. **Install FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Generate Firebase Options:**
   ```bash
   flutterfire configure
   ```

3. **Follow the prompts:**
   - Select your Firebase project
   - Select platforms (Android, iOS if needed)
   - The CLI will automatically generate `lib/firebase_options.dart`

### **Option 2: Manual Setup (If CLI doesn't work)**

1. **Go to Firebase Console:**
   - Open https://console.firebase.google.com/
   - Select your project

2. **Get Android App Configuration:**
   - Go to Project Settings → Your Apps → Android App
   - Copy the following values:
     - `apiKey`
     - `appId`
     - `messagingSenderId`
     - `projectId`

3. **Create `lib/firebase_options.dart` manually:**
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
       apiKey: 'YOUR_API_KEY',
       appId: 'YOUR_APP_ID',
       messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
       projectId: 'YOUR_PROJECT_ID',
     );
   }
   ```

4. **Update `lib/main.dart` to use firebase_options:**
   ```dart
   import 'firebase_options.dart';
   
   // In main() function:
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

---

## 📝 Update main.dart to Use firebase_options

After generating `firebase_options.dart`, update `lib/main.dart`:

**Current code:**
```dart
await Firebase.initializeApp();
```

**Updated code:**
```dart
import 'firebase_options.dart'; // Add this import at the top

// In main() function:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## 🧪 Testing

### **1. Test FCM Token Registration**

After logging in, check the console logs:
- You should see: `✅ FCM token registered successfully`
- Token should be printed: `📱 FCM Token: ...`

### **2. Test Push Notifications**

**From Backend:**
- Create a notification via admin panel
- Check if push notification appears on device

**From Firebase Console:**
1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter FCM token (from app logs)
4. Send test notification
5. Check if notification appears on device

### **3. Test Notification Scenarios**

- ✅ **Foreground:** App is open → Notification should appear as local notification
- ✅ **Background:** App is in background → Notification should appear in system tray
- ✅ **Terminated:** App is closed → Notification should appear, tapping opens app

---

## 🔍 Troubleshooting

### **Issue: Firebase not initialized**

**Solution:**
- Make sure `firebase_options.dart` exists
- Check if `google-services.json` is in `android/app/`
- Verify Firebase project is linked correctly

### **Issue: No FCM token**

**Solution:**
- Check notification permissions are granted
- Verify `google-services.json` is correct
- Check console logs for errors

### **Issue: Notifications not appearing**

**Solution:**
- Check notification permissions
- Verify FCM token is registered with backend
- Check backend is sending notifications correctly
- Check Android notification channel is created

### **Issue: Token registration fails**

**Solution:**
- Verify user is logged in (JWT token exists)
- Check backend API endpoint is working
- Check network connectivity
- Review console logs for error messages

---

## 📋 Checklist

- [ ] Generate `firebase_options.dart` using FlutterFire CLI
- [ ] Update `main.dart` to use `DefaultFirebaseOptions.currentPlatform`
- [ ] Run `flutter pub get`
- [ ] Build and run the app
- [ ] Test login → FCM token should be registered
- [ ] Test push notification from backend
- [ ] Test notification tap navigation

---

## 🎯 What Happens Now?

### **On App Startup:**
1. Firebase initializes
2. FCM service initializes
3. Notification permissions requested
4. FCM token obtained
5. If user is logged in → Token registered with backend

### **On Login:**
1. FCM token sent to backend with login request
2. After successful login → Token registered separately
3. Backend can now send push notifications

### **When Notification Arrives:**
1. **Foreground:** Local notification shown
2. **Background:** System notification shown
3. **Terminated:** System notification shown, app opens on tap

### **On Notification Tap:**
1. App opens (if closed)
2. Navigation handled based on notification data
3. User sees relevant screen

---

## 📚 Additional Resources

- **Firebase Console:** https://console.firebase.google.com/
- **FlutterFire Docs:** https://firebase.flutter.dev/
- **FCM Documentation:** https://firebase.google.com/docs/cloud-messaging

---

## ✅ Implementation Status

| Feature | Status |
|---------|--------|
| FCM Service | ✅ Complete |
| Token Registration | ✅ Complete |
| Login Integration | ✅ Complete |
| Foreground Notifications | ✅ Complete |
| Background Notifications | ✅ Complete |
| Notification Navigation | ✅ Complete |
| Android Permissions | ✅ Complete |
| Firebase Options | ⚠️ **Needs Generation** |

---

**Next Step:** Generate `firebase_options.dart` and update `main.dart` as described above!

