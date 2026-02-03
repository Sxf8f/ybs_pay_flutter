import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Service to handle biometric authentication (fingerprint, face, etc.)
/// Falls back to device PIN/password/pattern if biometrics fail or aren't available
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  static Future<bool> isAvailable() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();
      
      print('🔐 Biometric availability check:');
      print('   - Device supported: $isDeviceSupported');
      print('   - Can check biometrics: $canCheckBiometrics');
      print('   - Available biometrics: $availableBiometrics');
      
      // Device is supported if either condition is true
      final isAvailable = isDeviceSupported || canCheckBiometrics;
      print('   - Final result: $isAvailable');
      
      return isAvailable;
    } catch (e) {
      print('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if device has biometrics enrolled
  static Future<bool> hasEnrolledBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      print('Error checking enrolled biometrics: $e');
      return false;
    }
  }

  /// Authenticate using biometrics with fallback to device credentials
  /// Returns true if authentication succeeds, false otherwise
  static Future<bool> authenticate({
    String reason = 'Authenticate to access the app',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if biometrics are available
      final isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        print('Biometrics not available, attempting device credentials...');
        // Try to authenticate with device credentials (PIN/password/pattern)
        return await _authenticateWithDeviceCredentials(reason: reason);
      }

      // Check if biometrics are enrolled
      final hasEnrolled = await hasEnrolledBiometrics();
      if (!hasEnrolled) {
        print('No biometrics enrolled, attempting device credentials...');
        return await _authenticateWithDeviceCredentials(reason: reason);
      }

      // Try biometric authentication first
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow fallback to device credentials
        ),
      );

      if (authenticated) {
        print('✅ Biometric authentication successful');
        return true;
      }

      // If biometric auth failed, try device credentials
      print('Biometric authentication failed, attempting device credentials...');
      return await _authenticateWithDeviceCredentials(reason: reason);
    } on PlatformException catch (e) {
      print('Biometric authentication error: ${e.code} - ${e.message}');
      
      // Handle specific errors
      if (e.code == 'NotAvailable') {
        // Biometrics not available, try device credentials
        return await _authenticateWithDeviceCredentials(reason: reason);
      } else if (e.code == 'NotEnrolled') {
        // No biometrics enrolled, try device credentials
        return await _authenticateWithDeviceCredentials(reason: reason);
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        // Too many failed attempts, must use device credentials
        print('Biometrics locked out, using device credentials...');
        return await _authenticateWithDeviceCredentials(reason: reason);
      }
      
      return false;
    } catch (e) {
      print('Unexpected error during biometric authentication: $e');
      // Try device credentials as fallback
      return await _authenticateWithDeviceCredentials(reason: reason);
    }
  }

  /// Authenticate using device credentials (PIN/password/pattern)
  /// This is the fallback when biometrics fail or aren't available
  static Future<bool> _authenticateWithDeviceCredentials({
    required String reason,
  }) async {
    try {
      // On Android, setting biometricOnly: false allows fallback to device credentials
      // On iOS, it will prompt for device passcode
      final authenticated = await _auth.authenticate(
        localizedReason: 'Use your device PIN, password, or pattern to unlock',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false, // Allow device credentials
        ),
      );

      if (authenticated) {
        print('✅ Device credentials authentication successful');
        return true;
      }

      return false;
    } catch (e) {
      print('Error during device credentials authentication: $e');
      return false;
    }
  }

  /// Stop any ongoing authentication
  static Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  /// Get a user-friendly name for the available biometric type
  static Future<String> getBiometricTypeName() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris';
      } else if (availableBiometrics.contains(BiometricType.strong)) {
        return 'Biometric';
      } else if (availableBiometrics.contains(BiometricType.weak)) {
        return 'Biometric';
      }
      
      return 'Device Credentials';
    } catch (e) {
      return 'Device Credentials';
    }
  }
}
