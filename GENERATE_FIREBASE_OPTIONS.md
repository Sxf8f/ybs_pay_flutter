# 🔥 Generate Firebase Options File

## Method 1: Using FlutterFire CLI (Interactive)

Since `flutterfire configure` is an interactive command, you need to run it manually in your terminal:

### **Steps:**

1. **Open PowerShell/Terminal in your project root:**
   ```powershell
   cd C:\Users\User\AndroidStudioProjects\ybs_pay
   ```

2. **Run the command:**
   ```powershell
   dart pub global run flutterfire_cli:flutterfire configure
   ```

3. **Follow the interactive prompts:**
   - It will ask you to select your Firebase project
   - Select **Android** platform (and iOS if needed)
   - The CLI will automatically generate `lib/firebase_options.dart`

4. **After generation, update `lib/main.dart`:**
   - Uncomment the import and update the Firebase initialization as shown in the TODO comment

---

## Method 2: Manual Creation (If CLI doesn't work)

If the CLI doesn't work, you can manually create the file:

### **Step 1: Get Firebase Configuration**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon) → **Your apps** → **Android app**
4. Copy these values:
   - `apiKey`
   - `appId` (Application ID)
   - `messagingSenderId`
   - `projectId`

### **Step 2: Create `lib/firebase_options.dart`**

Create the file with this template:

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
    apiKey: 'YOUR_API_KEY_HERE',
    appId: 'YOUR_APP_ID_HERE',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    // Optional: Add storage bucket if needed
    // storageBucket: 'YOUR_STORAGE_BUCKET_HERE',
  );
}
```

### **Step 3: Replace Placeholders**

Replace the placeholder values with your actual Firebase configuration values.

### **Step 4: Update `lib/main.dart`**

After creating the file, update `lib/main.dart`:

**Find this:**
```dart
// TODO: After generating firebase_options.dart using 'flutterfire configure',
// uncomment the import below and update the initialization:
// import 'firebase_options.dart';
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );

await Firebase.initializeApp();
```

**Replace with:**
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## Method 3: Add to PATH (Optional - for future use)

If you want to use `flutterfire` command directly without `dart pub global run`:

1. **Add to PATH:**
   - Open **System Properties** → **Environment Variables**
   - Edit **Path** variable
   - Add: `C:\Users\User\AppData\Local\Pub\Cache\bin`
   - Click **OK** and restart terminal

2. **Now you can use:**
   ```powershell
   flutterfire configure
   ```

---

## Verification

After generating/creating `firebase_options.dart`:

1. ✅ File exists at `lib/firebase_options.dart`
2. ✅ `lib/main.dart` is updated to use it
3. ✅ Run `flutter pub get`
4. ✅ Build and run the app
5. ✅ Check console for: `✅ Firebase initialized`

---

## Troubleshooting

### **Issue: CLI command doesn't work**

**Solution:** Use Method 2 (Manual Creation) instead.

### **Issue: Can't find Firebase project**

**Solution:** 
- Make sure you're logged into Firebase CLI: `firebase login`
- Or use Method 2 (Manual Creation)

### **Issue: Wrong project selected**

**Solution:**
- Delete `lib/firebase_options.dart`
- Run `flutterfire configure` again
- Select the correct project

---

**Recommended:** Try Method 1 first (interactive CLI), if it doesn't work, use Method 2 (manual creation).

