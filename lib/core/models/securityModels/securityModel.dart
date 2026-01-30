class DoubleFactorStatusResponse {
  final bool success;
  final bool doubleFactorEnabled;
  final bool hasSecureKey;
  final String message;

  DoubleFactorStatusResponse({
    required this.success,
    required this.doubleFactorEnabled,
    required this.hasSecureKey,
    required this.message,
  });

  factory DoubleFactorStatusResponse.fromJson(Map<String, dynamic> json) {
    return DoubleFactorStatusResponse(
      success: json['success'] ?? false,
      doubleFactorEnabled: json['double_factor_enabled'] ?? false,
      hasSecureKey: json['has_secure_key'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}

class ToggleDoubleFactorResponse {
  final bool success;
  final bool doubleFactorEnabled;
  final String message;

  ToggleDoubleFactorResponse({
    required this.success,
    required this.doubleFactorEnabled,
    required this.message,
  });

  factory ToggleDoubleFactorResponse.fromJson(Map<String, dynamic> json) {
    return ToggleDoubleFactorResponse(
      success: json['success'] ?? false,
      doubleFactorEnabled: json['double_factor_enabled'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}

class ChangePinPasswordResponse {
  final bool success;
  final String message;
  final bool doubleFactorEnabled;

  ChangePinPasswordResponse({
    required this.success,
    required this.message,
    required this.doubleFactorEnabled,
  });

  factory ChangePinPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePinPasswordResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      doubleFactorEnabled: json['double_factor_enabled'] ?? false,
    );
  }
}

class SecureKeyStatusResponse {
  final bool success;
  final bool secureKeyEnabled;
  final bool hasSecureKey;
  final bool requiresSecureKey;
  final String message;

  SecureKeyStatusResponse({
    required this.success,
    required this.secureKeyEnabled,
    required this.hasSecureKey,
    required this.requiresSecureKey,
    required this.message,
  });

  factory SecureKeyStatusResponse.fromJson(Map<String, dynamic> json) {
    return SecureKeyStatusResponse(
      success: json['success'] ?? false,
      secureKeyEnabled: json['secure_key_enabled'] ?? false,
      hasSecureKey: json['has_secure_key'] ?? false,
      requiresSecureKey: json['requires_secure_key'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}

class ValidateSecureKeyResponse {
  final bool success;
  final bool valid;
  final String message;
  final String? error;

  ValidateSecureKeyResponse({
    required this.success,
    required this.valid,
    required this.message,
    this.error,
  });

  factory ValidateSecureKeyResponse.fromJson(Map<String, dynamic> json) {
    return ValidateSecureKeyResponse(
      success: json['success'] ?? false,
      valid: json['valid'] ?? false,
      message: json['message']?.toString() ?? '',
      error: json['error']?.toString(),
    );
  }
}

class RegenerateSecureKeyResponse {
  final bool success;
  final String message;
  final String phoneNumber;
  final bool secureKeySent;
  final String? newSecureKey;
  final bool doubleFactorEnabled;
  final String? warning;

  RegenerateSecureKeyResponse({
    required this.success,
    required this.message,
    required this.phoneNumber,
    required this.secureKeySent,
    this.newSecureKey,
    required this.doubleFactorEnabled,
    this.warning,
  });

  factory RegenerateSecureKeyResponse.fromJson(Map<String, dynamic> json) {
    return RegenerateSecureKeyResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      secureKeySent: json['secure_key_sent'] ?? false,
      newSecureKey: json['new_secure_key']?.toString(),
      doubleFactorEnabled: json['double_factor_enabled'] ?? false,
      warning: json['warning']?.toString(),
    );
  }
}

