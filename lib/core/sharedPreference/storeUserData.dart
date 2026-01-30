import 'package:shared_preferences/shared_preferences.dart';
import '../auth/tokenManager.dart';

Future<void> storeLoginData(Map<String, dynamic> response) async {
  final prefs = await SharedPreferences.getInstance();

  // Helper function to safely convert to int
  int _toInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  await prefs.setInt('user_id', _toInt(response['user_id'], 0));
  await prefs.setString('username', response['username'] ?? response['login_user_id'] ?? '');
  await prefs.setInt('role_id', _toInt(response['role_id'], 0));
  await prefs.setString('role_name', response['role_name'] ?? '');
  
  // Store tokens using TokenManager
  final accessToken = response['access']?.toString().trim() ?? response['token']?.toString().trim() ?? '';
  final refreshToken = response['refresh']?.toString().trim() ?? '';
  
  if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
    // Calculate expiration time
    int? expiresIn = response['expires_in'];
    DateTime? expiresAt;
    
    if (response['expires_at'] != null) {
      try {
        expiresAt = DateTime.parse(response['expires_at']);
      } catch (e) {
        print('Error parsing expires_at: $e');
      }
    }
    
    // Store tokens with expiration
    await TokenManager.storeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      expiresAt: expiresAt,
    );
    
    print('Tokens stored successfully with expiration tracking');
  } else {
    print('WARNING: Access token or refresh token is empty in login response!');
    print('Login response keys: ${response.keys.toList()}');
    
    // Fallback: store tokens directly if TokenManager fails
    if (accessToken.isNotEmpty) {
      await prefs.setString('access_token', accessToken);
    }
    if (refreshToken.isNotEmpty) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }
  
  // Store additional fields if available
  if (response['name'] != null) {
    await prefs.setString('name', response['name']);
  }
  if (response['email'] != null) {
    await prefs.setString('email', response['email']);
  }
  if (response['phone'] != null) {
    await prefs.setString('phone', response['phone']);
  }
  if (response['login_user_id'] != null) {
    await prefs.setString('login_user_id', response['login_user_id']);
  }
  if (response['login_type'] != null) {
    await prefs.setString('login_type', response['login_type']);
  }
}
