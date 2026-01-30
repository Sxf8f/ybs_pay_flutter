import 'dart:convert';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/core/sharedPreference/storeUserData.dart';
import '../../models/authModels/userModel.dart';
import '../../auth/httpClient.dart';

class signInAuthRepository {
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

    // Set proper headers for JSON content
    final headers = {
      'Content-Type': 'application/json',
    };

    // Use SSL-aware client to handle certificate issues
    final client = AuthenticatedHttpClient.getSslAwareClient();
    try {
      final response = await client.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);
      print('Login response: ${data}');

      if (response.statusCode == 200) {
        // Check if OTP is required
        if (data['status'] == 'otp_sent') {
          throw OtpRequiredException(
            userId: data['user_id']?.toString() ?? userId,
            loginType: data['login_type']?.toString() ?? 'email',
            message: data['message']?.toString() ?? 'OTP sent to your WhatsApp number.',
          );
        }

        // Check if login was successful
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
        } else {
          // Handle other status values
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        // Handle error responses
        final errorMessage = _parseErrorResponse(data);
        throw Exception(errorMessage);
      }
    } finally {
      client.close();
    }
  }

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

    // Set proper headers for JSON content
    final headers = {
      'Content-Type': 'application/json',
    };

    // Use SSL-aware client to handle certificate issues
    final client = AuthenticatedHttpClient.getSslAwareClient();
    try {
      final response = await client.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);
      print('OTP Verification response: ${data}');

      if (response.statusCode == 200) {
        // Check if OTP was verified successfully
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
        } else {
          throw Exception(data['message'] ?? 'OTP verification failed');
        }
      } else {
        // Handle error responses
        final errorMessage = _parseErrorResponse(data);
        throw Exception(errorMessage);
      }
    } finally {
      client.close();
    }
  }

  String _parseErrorResponse(Map<String, dynamic> errorData) {
    // Handle field-specific validation errors
    if (errorData.containsKey('non_field_errors')) {
      final nonFieldErrors = errorData['non_field_errors'];
      if (nonFieldErrors is List && nonFieldErrors.isNotEmpty) {
        return nonFieldErrors[0].toString();
      }
    }

    // Handle status/message format
    if (errorData.containsKey('message')) {
      return errorData['message'].toString();
    }

    // Handle status/error format
    if (errorData.containsKey('status') && errorData['status'] == 'error') {
      return errorData['message']?.toString() ?? 'Login failed';
    }

    // Handle invalid status
    if (errorData.containsKey('status') && errorData['status'] == 'invalid') {
      return errorData['message']?.toString() ?? 'Invalid or expired OTP';
    }

    // Fallback to generic error
    return 'Login failed. Please try again.';
  }
}

// Custom exception for OTP required
class OtpRequiredException implements Exception {
  final String userId;
  final String loginType;
  final String message;

  OtpRequiredException({
    required this.userId,
    required this.loginType,
    required this.message,
  });

  @override
  String toString() => message;
}

// Custom exception for unauthorized role
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
