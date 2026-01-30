import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/authModels/forgotPasswordModel.dart';
import '../../auth/httpClient.dart';

class ForgotPasswordRepository {
  Future<ForgotPasswordResponse> forgotPassword(String emailOrPhone) async {
    try {
      final url = Uri.parse('${AssetsConst.apiBase}api/android/forgot-password/');
      
      print('🔐 [FORGOT_PASSWORD] API Call:');
      print('   URL: $url');
      print('   Email/Phone: $emailOrPhone');

      final request = ForgotPasswordRequest(emailOrPhone: emailOrPhone);
      // Use SSL-aware client to handle certificate issues
      final client = AuthenticatedHttpClient.getSslAwareClient();
      try {
        final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
        ).timeout(const Duration(seconds: 30));

      print('🔐 [FORGOT_PASSWORD] Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final forgotPasswordResponse = ForgotPasswordResponse.fromJson(data);
        
        if (forgotPasswordResponse.success) {
          print('   ✅ Success: ${forgotPasswordResponse.message}');
          print('   Sent via: ${forgotPasswordResponse.sentVia}');
          print('   Contact: ${forgotPasswordResponse.contact}');
        } else {
          print('   ❌ Error: ${forgotPasswordResponse.error}');
        }
        
        return forgotPasswordResponse;
      } else {
        // Try to parse error response
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 
              errorData['message'] ?? 
              'Failed to reset password';
          
          print('   ❌ Error Response: $errorMessage');
          
          return ForgotPasswordResponse(
            success: false,
            error: errorMessage,
          );
        } catch (e) {
          print('   ❌ Failed to parse error response: $e');
          return ForgotPasswordResponse(
            success: false,
            error: 'Failed to reset password (Status: ${response.statusCode})',
          );
        }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('🔐 [FORGOT_PASSWORD] Exception: $e');
      return ForgotPasswordResponse(
        success: false,
        error: 'Network error. Please check your internet connection and try again.',
      );
    }
  }
}
