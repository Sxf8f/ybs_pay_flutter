// Fund Transfer Models (Distributor Only)

class FundTransferSearchUsersResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<FundTransferUser> users;
  final String? message;

  FundTransferSearchUsersResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.users,
    this.message,
  });

  factory FundTransferSearchUsersResponse.fromJson(Map<String, dynamic> json) {
    return FundTransferSearchUsersResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => FundTransferUser.fromJson(e))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

class FundTransferUser {
  final int id;
  final String username;
  final String? name;
  final String? phone;
  final String? email;
  final String? role;
  final String balance;

  FundTransferUser({
    required this.id,
    required this.username,
    this.name,
    this.phone,
    this.email,
    this.role,
    required this.balance,
  });

  factory FundTransferUser.fromJson(Map<String, dynamic> json) {
    return FundTransferUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      balance: json['balance'] ?? '0.00',
    );
  }
}

class FundTransferResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String? amount;
  final FundTransferTransactionUser? sender;
  final FundTransferTransactionUser? receiver;
  final String? timestamp;
  final String? error;
  final bool? requiresSecureKey;
  final String? currentBalance;
  final String? requiredAmount;

  FundTransferResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.amount,
    this.sender,
    this.receiver,
    this.timestamp,
    this.error,
    this.requiresSecureKey,
    this.currentBalance,
    this.requiredAmount,
  });

  factory FundTransferResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 [Fund Transfer Model] Parsing response: $json');
    
    // Parse sender
    FundTransferTransactionUser? sender;
    if (json['sender'] != null && json['sender'] is Map<String, dynamic>) {
      sender = FundTransferTransactionUser.fromJson(json['sender'] as Map<String, dynamic>);
    }
    
    // Parse receiver
    FundTransferTransactionUser? receiver;
    if (json['receiver'] != null && json['receiver'] is Map<String, dynamic>) {
      receiver = FundTransferTransactionUser.fromJson(json['receiver'] as Map<String, dynamic>);
    }
    
    final response = FundTransferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? json['error'] ?? '',
      transactionId: json['transaction_id']?.toString(),
      amount: json['amount']?.toString(),
      sender: sender,
      receiver: receiver,
      timestamp: json['timestamp']?.toString(),
      error: json['error']?.toString(),
      requiresSecureKey: json['requires_secure_key'] == true || json['requires_secure_key'] == 'true',
      currentBalance: json['current_balance']?.toString(),
      requiredAmount: json['required_amount']?.toString(),
    );
    
    print('🔍 [Fund Transfer Model] Parsed response:');
    print('   Success: ${response.success}');
    print('   Error: ${response.error}');
    print('   Requires Secure Key: ${response.requiresSecureKey}');
    print('   Current Balance: ${response.currentBalance}');
    print('   Required Amount: ${response.requiredAmount}');
    
    return response;
  }
}

class FundTransferTransactionUser {
  final int id;
  final String username;
  final String? phone;
  final String? oldBalance;
  final String? newBalance;

  FundTransferTransactionUser({
    required this.id,
    required this.username,
    this.phone,
    this.oldBalance,
    this.newBalance,
  });

  factory FundTransferTransactionUser.fromJson(Map<String, dynamic> json) {
    return FundTransferTransactionUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      phone: json['phone']?.toString(),
      oldBalance: json['old_balance']?.toString(),
      newBalance: json['new_balance']?.toString(),
    );
  }
}

