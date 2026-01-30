// Scan & Pay Models (Distributor Only)

class GenerateQRResponse {
  final bool success;
  final String qrData;
  final String? qrImageUrl;
  final int userId;
  final String? userName;
  final String? userPhone;
  final String? message;

  GenerateQRResponse({
    required this.success,
    required this.qrData,
    this.qrImageUrl,
    required this.userId,
    this.userName,
    this.userPhone,
    this.message,
  });

  factory GenerateQRResponse.fromJson(Map<String, dynamic> json) {
    return GenerateQRResponse(
      success: json['success'] ?? false,
      qrData: json['qr_data'] ?? '',
      qrImageUrl: json['qr_image_url'],
      userId: json['user_id'] ?? 0,
      userName: json['user_name'],
      userPhone: json['user_phone'],
      message: json['message'],
    );
  }
}

class ValidateQRResponse {
  final bool success;
  final bool valid;
  final QRRecipient? recipient;
  final String? error;
  final String? message;

  ValidateQRResponse({
    required this.success,
    required this.valid,
    this.recipient,
    this.error,
    this.message,
  });

  factory ValidateQRResponse.fromJson(Map<String, dynamic> json) {
    return ValidateQRResponse(
      success: json['success'] ?? false,
      valid: json['valid'] ?? false,
      recipient: json['recipient'] != null
          ? QRRecipient.fromJson(json['recipient'])
          : null,
      error: json['error'],
      message: json['message'],
    );
  }
}

class QRRecipient {
  final int id;
  final String username;
  final String? name;
  final String? phone;
  final String? email;

  QRRecipient({
    required this.id,
    required this.username,
    this.name,
    this.phone,
    this.email,
  });

  factory QRRecipient.fromJson(Map<String, dynamic> json) {
    return QRRecipient(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class QRTransferResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String? amount;
  final QRTransferUser? sender;
  final QRTransferUser? recipient;
  final String? error;
  final bool? requiresSecureKey;

  QRTransferResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.amount,
    this.sender,
    this.recipient,
    this.error,
    this.requiresSecureKey,
  });

  factory QRTransferResponse.fromJson(Map<String, dynamic> json) {
    return QRTransferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactionId: json['transaction_id'],
      amount: json['amount']?.toString(),
      sender: (json['sender'] != null)
          ? QRTransferUser.fromJson(json['sender'])
          : null,
      recipient: (json['recipient'] != null)
          ? QRTransferUser.fromJson(json['recipient'])
          : null,
      error: json['error'],
      requiresSecureKey: json['requires_secure_key'],
    );
  }
}

class QRTransferUser {
  final int id;
  final String? username;
  final String? phone;
  final String? oldBalance;
  final String? newBalance;

  QRTransferUser({
    required this.id,
    this.username,
    this.phone,
    this.oldBalance,
    this.newBalance,
  });

  factory QRTransferUser.fromJson(Map<String, dynamic> json) {
    return QRTransferUser(
      id: json['id'] ?? 0,
      username: json['username'],
      phone: json['phone'],
      oldBalance: json['old_balance']?.toString(),
      newBalance: json['new_balance']?.toString(),
    );
  }
}

