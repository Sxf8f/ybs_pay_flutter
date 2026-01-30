class ForgotPasswordRequest {
  final String emailOrPhone;

  ForgotPasswordRequest({required this.emailOrPhone});

  Map<String, dynamic> toJson() {
    return {
      'email_or_phone': emailOrPhone,
    };
  }
}

class ForgotPasswordResponse {
  final bool success;
  final String? message;
  final String? sentVia;
  final String? contact;
  final String? error;

  ForgotPasswordResponse({
    required this.success,
    this.message,
    this.sentVia,
    this.contact,
    this.error,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'],
      sentVia: json['sent_via'],
      contact: json['contact'],
      error: json['error'],
    );
  }
}
