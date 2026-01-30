import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/securityModels/securityModel.dart';
import '../../auth/httpClient.dart';

class SecurityRepository {
  /// Get current double factor authentication status
  Future<DoubleFactorStatusResponse> getDoubleFactorStatus() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/security/toggle-double-factor/');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return DoubleFactorStatusResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch double factor status';
      throw Exception(errorMsg);
    }
  }

  /// Toggle double factor authentication
  Future<ToggleDoubleFactorResponse> toggleDoubleFactor(bool enabled) async {
    final body = {
      'enabled': enabled,
    };

    final url = Uri.parse('${AssetsConst.apiBase}api/android/security/toggle-double-factor/');
    
    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ToggleDoubleFactorResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to toggle double factor';
      throw Exception(errorMsg);
    }
  }

  /// Change pin password (secure key)
  Future<ChangePinPasswordResponse> changePinPassword({
    String? currentPin,
    required String newPin,
    required String confirmPin,
  }) async {
    final bodyMap = <String, dynamic>{
      'new_pin': newPin,
      'confirm_pin': confirmPin,
    };
    if (currentPin != null && currentPin.isNotEmpty) {
      bodyMap['current_pin'] = currentPin;
    }

    final url = Uri.parse('${AssetsConst.apiBase}api/android/security/change-pin-password/');
    
    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: bodyMap,
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ChangePinPasswordResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to change pin password';
      throw Exception(errorMsg);
    }
  }

  /// Check secure key status
  Future<SecureKeyStatusResponse> checkSecureKeyStatus() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/security/check-status/');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return SecureKeyStatusResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to check secure key status';
      throw Exception(errorMsg);
    }
  }

  /// Validate secure key
  Future<ValidateSecureKeyResponse> validateSecureKey(String secureKey) async {
    final body = {
      'secure_key': secureKey,
    };

    final url = Uri.parse('${AssetsConst.apiBase}api/android/security/validate/');
    
    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ValidateSecureKeyResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      // Invalid secure key
      return ValidateSecureKeyResponse(
        success: false,
        valid: false,
        message: data['message'] ?? 'Invalid secure key',
        error: data['error']?.toString(),
      );
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to validate secure key';
      throw Exception(errorMsg);
    }
  }

  /// Regenerate secure key
  Future<RegenerateSecureKeyResponse> regenerateSecureKey() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/security/regenerate-key/');
    
    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {},
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return RegenerateSecureKeyResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to regenerate secure key';
      throw Exception(errorMsg);
    }
  }
}
