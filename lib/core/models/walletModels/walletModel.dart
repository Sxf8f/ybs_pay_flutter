class WalletBalanceResponse {
  final bool success;
  final String balance;
  final String balanceFormatted;
  final int? userId;
  final String? username;

  WalletBalanceResponse({
    required this.success,
    required this.balance,
    required this.balanceFormatted,
    this.userId,
    this.username,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      success: json['success'] ?? false,
      balance: json['balance']?.toString() ?? '0.00',
      balanceFormatted: json['balance_formatted'] ?? '₹0.00',
      userId: json['user_id'],
      username: json['username'],
    );
  }
}

class ChargeInfo {
  final double charge;
  final bool isFixed;
  final String chargeDisplay;
  final String chargeType;
  final double minAmount;
  final double maxAmount;
  final String minAmountDisplay;
  final String maxAmountDisplay;

  ChargeInfo({
    required this.charge,
    required this.isFixed,
    required this.chargeDisplay,
    required this.chargeType,
    required this.minAmount,
    required this.maxAmount,
    required this.minAmountDisplay,
    required this.maxAmountDisplay,
  });

  factory ChargeInfo.fromJson(Map<String, dynamic> json) {
    return ChargeInfo(
      charge: (json['charge'] is int) 
          ? (json['charge'] as int).toDouble() 
          : (json['charge'] is double) 
              ? json['charge'] 
              : double.tryParse(json['charge'].toString()) ?? 0.0,
      isFixed: json['is_fixed'] ?? false,
      chargeDisplay: json['charge_display'] ?? '₹0.00',
      chargeType: json['charge_type'] ?? 'Fixed',
      minAmount: (json['min_amount'] is int)
          ? (json['min_amount'] as int).toDouble()
          : (json['min_amount'] is double)
              ? json['min_amount']
              : double.tryParse(json['min_amount'].toString()) ?? 0.0,
      maxAmount: (json['max_amount'] is int)
          ? (json['max_amount'] as int).toDouble()
          : (json['max_amount'] is double)
              ? json['max_amount']
              : double.tryParse(json['max_amount'].toString()) ?? 0.0,
      minAmountDisplay: json['min_amount_display'] ?? '₹0.00',
      maxAmountDisplay: json['max_amount_display'] ?? '₹0.00',
    );
  }
}

class PaymentMethod {
  final String operator;
  final String operatorDisplay;
  final int gatewayId;
  final String gatewayName;
  final bool isActive;
  final ChargeInfo? chargeInfo;

  PaymentMethod({
    required this.operator,
    required this.operatorDisplay,
    required this.gatewayId,
    required this.gatewayName,
    required this.isActive,
    this.chargeInfo,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      operator: json['operator'] ?? '',
      operatorDisplay: json['operator_display'] ?? '',
      gatewayId: json['gateway_id'] ?? 0,
      gatewayName: json['gateway_name'] ?? '',
      isActive: json['is_active'] ?? false,
      chargeInfo: json['charge_info'] != null 
          ? ChargeInfo.fromJson(json['charge_info']) 
          : null,
    );
  }
}

class PaymentMethodsResponse {
  final bool success;
  final bool pgActive;
  final List<PaymentMethod> paymentMethods;
  final int totalCount;
  final String? message;
  final double? currentBalance;
  final String? currentBalanceDisplay;

  PaymentMethodsResponse({
    required this.success,
    required this.pgActive,
    required this.paymentMethods,
    required this.totalCount,
    this.message,
    this.currentBalance,
    this.currentBalanceDisplay,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    double? currentBalance;
    if (json['current_balance'] != null) {
      if (json['current_balance'] is int) {
        currentBalance = (json['current_balance'] as int).toDouble();
      } else if (json['current_balance'] is double) {
        currentBalance = json['current_balance'];
      } else {
        currentBalance = double.tryParse(json['current_balance'].toString());
      }
    }

    return PaymentMethodsResponse(
      success: json['success'] ?? false,
      pgActive: json['pg_active'] ?? false,
      paymentMethods: (json['payment_methods'] as List<dynamic>?)
              ?.map((e) => PaymentMethod.fromJson(e))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      message: json['message'],
      currentBalance: currentBalance,
      currentBalanceDisplay: json['current_balance_display'],
    );
  }
}

class UPIIntentLinks {
  final String? bhimLink;
  final String? phonepeLink;
  final String? paytmLink;
  final String? gpayLink;

  UPIIntentLinks({
    this.bhimLink,
    this.phonepeLink,
    this.paytmLink,
    this.gpayLink,
  });

  factory UPIIntentLinks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UPIIntentLinks();
    
    return UPIIntentLinks(
      bhimLink: json['bhim_link']?.toString(),
      phonepeLink: json['phonepe_link']?.toString(),
      paytmLink: json['paytm_link']?.toString(),
      gpayLink: json['gpay_link']?.toString(),
    );
  }
}

class AddMoneyResponse {
  final bool success;
  final String message;
  final String transactionId;
  final String? liveId;
  final String amount;
  final String? paymentUrl;
  final String? upiUrl;
  final UPIIntentLinks? upiIntentLinks; // New field for specific UPI app links
  final String status;
  final bool redirect;
  final String? gatewayName;
  final String? operator;
  final String? oldBalance;
  final String? newBalance;
  final double? charge;
  final double? netAmount;
  final String? chargeType;

  AddMoneyResponse({
    required this.success,
    required this.message,
    required this.transactionId,
    this.liveId,
    required this.amount,
    this.paymentUrl,
    this.upiUrl,
    this.upiIntentLinks,
    required this.status,
    required this.redirect,
    this.gatewayName,
    this.operator,
    this.oldBalance,
    this.newBalance,
    this.charge,
    this.netAmount,
    this.chargeType,
  });

  factory AddMoneyResponse.fromJson(Map<String, dynamic> json) {
    print('=== AddMoneyResponse.fromJson ===');
    print('Input JSON: $json');
    
    // Safely convert transaction_id (might be int or String)
    String transactionId;
    final transactionIdValue = json['transaction_id'];
    if (transactionIdValue == null) {
      transactionId = '';
    } else if (transactionIdValue is int) {
      transactionId = transactionIdValue.toString();
      print('Transaction ID converted from int: $transactionId');
    } else if (transactionIdValue is String) {
      transactionId = transactionIdValue;
    } else {
      transactionId = transactionIdValue.toString();
    }
    
    // Safely convert live_id (might be int or String)
    String? liveId;
    final liveIdValue = json['live_id'];
    if (liveIdValue == null) {
      liveId = null;
    } else if (liveIdValue is int) {
      liveId = liveIdValue.toString();
      print('Live ID converted from int: $liveId');
    } else if (liveIdValue is String) {
      liveId = liveIdValue;
    } else {
      liveId = liveIdValue.toString();
    }
    
    // Safely convert amount
    String amount;
    final amountValue = json['amount'];
    if (amountValue == null) {
      amount = '0.00';
    } else if (amountValue is int) {
      amount = amountValue.toStringAsFixed(2);
      print('Amount converted from int: $amount');
    } else if (amountValue is double) {
      amount = amountValue.toStringAsFixed(2);
    } else {
      amount = amountValue.toString();
    }
    
    // Safely convert old_balance
    String? oldBalance;
    final oldBalanceValue = json['old_balance'];
    if (oldBalanceValue == null) {
      oldBalance = null;
    } else if (oldBalanceValue is int) {
      oldBalance = oldBalanceValue.toString();
    } else if (oldBalanceValue is double) {
      oldBalance = oldBalanceValue.toStringAsFixed(2);
    } else {
      oldBalance = oldBalanceValue.toString();
    }
    
    // Safely convert new_balance
    String? newBalance;
    final newBalanceValue = json['new_balance'];
    if (newBalanceValue == null) {
      newBalance = null;
    } else if (newBalanceValue is int) {
      newBalance = newBalanceValue.toString();
    } else if (newBalanceValue is double) {
      newBalance = newBalanceValue.toStringAsFixed(2);
    } else {
      newBalance = newBalanceValue.toString();
    }
    
    // Safely convert status
    String status = 'PENDING';
    final statusValue = json['status'];
    if (statusValue != null) {
      if (statusValue is int) {
        status = statusValue.toString();
      } else {
        status = statusValue.toString();
      }
    }
    
    // Safely convert redirect
    bool redirect = false;
    final redirectValue = json['redirect'];
    if (redirectValue != null) {
      if (redirectValue is bool) {
        redirect = redirectValue;
      } else if (redirectValue is int) {
        redirect = redirectValue != 0;
      } else if (redirectValue is String) {
        redirect = redirectValue.toLowerCase() == 'true' || redirectValue == '1';
      }
    }
    
    // Debug: Check upi_url before parsing
    final upiUrlRaw = json['upi_url'];
    print('=== Parsing upi_url ===');
    print('upi_url raw value: $upiUrlRaw');
    print('upi_url type: ${upiUrlRaw?.runtimeType}');
    print('upi_url is null: ${upiUrlRaw == null}');
    print('upi_url toString: ${upiUrlRaw?.toString()}');
    
    // Parse charge
    double? charge;
    if (json['charge'] != null) {
      if (json['charge'] is int) {
        charge = (json['charge'] as int).toDouble();
      } else if (json['charge'] is double) {
        charge = json['charge'];
      } else {
        charge = double.tryParse(json['charge'].toString());
      }
    }

    // Parse net_amount
    double? netAmount;
    if (json['net_amount'] != null) {
      if (json['net_amount'] is int) {
        netAmount = (json['net_amount'] as int).toDouble();
      } else if (json['net_amount'] is double) {
        netAmount = json['net_amount'];
      } else {
        netAmount = double.tryParse(json['net_amount'].toString());
      }
    }

    // Parse UPI Intent Links (specific app links from PG response)
    UPIIntentLinks? upiIntentLinks;
    if (json['upi_intent'] != null && json['upi_intent'] is Map<String, dynamic>) {
      print('=== Parsing upi_intent ===');
      print('upi_intent raw value: ${json['upi_intent']}');
      upiIntentLinks = UPIIntentLinks.fromJson(json['upi_intent'] as Map<String, dynamic>);
      print('UPI Intent Links parsed:');
      print('  - BHIM Link: ${upiIntentLinks.bhimLink ?? "null"}');
      print('  - PhonePe Link: ${upiIntentLinks.phonepeLink ?? "null"}');
      print('  - Paytm Link: ${upiIntentLinks.paytmLink ?? "null"}');
      print('  - GPay Link: ${upiIntentLinks.gpayLink ?? "null"}');
    } else {
      print('=== upi_intent not found or invalid ===');
    }

    final response = AddMoneyResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      transactionId: transactionId,
      liveId: liveId,
      amount: amount,
      paymentUrl: json['payment_url']?.toString(),
      upiUrl: json['upi_url']?.toString(),
      upiIntentLinks: upiIntentLinks,
      status: status,
      redirect: redirect,
      gatewayName: json['gateway_name']?.toString(),
      operator: json['operator']?.toString(),
      oldBalance: oldBalance,
      newBalance: newBalance,
      charge: charge,
      netAmount: netAmount,
      chargeType: json['charge_type']?.toString(),
    );
    
    print('=== AddMoneyResponse CREATED ===');
    print('Transaction ID: ${response.transactionId} (type: ${response.transactionId.runtimeType})');
    print('Amount: ${response.amount} (type: ${response.amount.runtimeType})');
    print('Live ID: ${response.liveId} (type: ${response.liveId?.runtimeType})');
    print('UPI URL: ${response.upiUrl ?? "null"} (type: ${response.upiUrl?.runtimeType})');
    print('UPI URL is null: ${response.upiUrl == null}');
    print('UPI URL isEmpty: ${response.upiUrl?.isEmpty ?? true}');
    if (response.upiIntentLinks != null) {
      print('UPI Intent Links available:');
      print('  - BHIM: ${response.upiIntentLinks!.bhimLink ?? "null"}');
      print('  - PhonePe: ${response.upiIntentLinks!.phonepeLink ?? "null"}');
      print('  - Paytm: ${response.upiIntentLinks!.paytmLink ?? "null"}');
      print('  - GPay: ${response.upiIntentLinks!.gpayLink ?? "null"}');
    } else {
      print('UPI Intent Links: null');
    }
    
    return response;
  }
}

class PaymentStatusResponse {
  final bool success;
  final String transactionId;
  final String? liveId;
  final String amount;
  final String status;
  final String statusDisplay;
  final String remark;
  final String? requestDate;
  final String? approvalDate;
  final String? gatewayName;
  final String currentBalance;
  final String? currentBalanceDisplay;
  final Map<String, dynamic>? orderData;
  final double? charge;
  final double? netAmount;

  PaymentStatusResponse({
    required this.success,
    required this.transactionId,
    this.liveId,
    required this.amount,
    required this.status,
    required this.statusDisplay,
    required this.remark,
    this.requestDate,
    this.approvalDate,
    this.gatewayName,
    required this.currentBalance,
    this.currentBalanceDisplay,
    this.orderData,
    this.charge,
    this.netAmount,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    // Parse charge
    double? charge;
    if (json['charge'] != null) {
      if (json['charge'] is int) {
        charge = (json['charge'] as int).toDouble();
      } else if (json['charge'] is double) {
        charge = json['charge'];
      } else {
        charge = double.tryParse(json['charge'].toString());
      }
    }

    // Parse net_amount
    double? netAmount;
    if (json['net_amount'] != null) {
      if (json['net_amount'] is int) {
        netAmount = (json['net_amount'] as int).toDouble();
      } else if (json['net_amount'] is double) {
        netAmount = json['net_amount'];
      } else {
        netAmount = double.tryParse(json['net_amount'].toString());
      }
    }

    // Handle transaction object if present
    Map<String, dynamic>? transactionData;
    if (json['transaction'] != null && json['transaction'] is Map) {
      transactionData = json['transaction'] as Map<String, dynamic>;
    }

    // Use transaction data if available, otherwise use root level data
    final data = transactionData ?? json;

    return PaymentStatusResponse(
      success: json['success'] ?? false,
      transactionId: data['transaction_id']?.toString() ?? '',
      liveId: data['live_id']?.toString(),
      amount: data['amount']?.toString() ?? '0.00',
      status: data['status']?.toString() ?? 'PENDING',
      statusDisplay: data['status_display'] ?? data['status']?.toString() ?? 'PENDING',
      remark: data['remark']?.toString() ?? '',
      requestDate: data['request_date']?.toString(),
      approvalDate: data['approval_date']?.toString(),
      gatewayName: data['gateway']?.toString() ?? data['gateway_name']?.toString(),
      currentBalance: json['current_balance']?.toString() ?? '0.00',
      currentBalanceDisplay: json['current_balance_display'],
      orderData: json['order_data'],
      charge: charge ?? (data['charge'] != null 
          ? (data['charge'] is int 
              ? (data['charge'] as int).toDouble() 
              : (data['charge'] is double 
                  ? data['charge'] 
                  : double.tryParse(data['charge'].toString())))
          : null),
      netAmount: netAmount ?? (data['net_amount'] != null
          ? (data['net_amount'] is int
              ? (data['net_amount'] as int).toDouble()
              : (data['net_amount'] is double
                  ? data['net_amount']
                  : double.tryParse(data['net_amount'].toString())))
          : null),
    );
  }
}

class WalletTransaction {
  final int id;
  final String transactionId;
  final String? liveId;
  final String amount;
  final String transactionCharges;
  final String status;
  final int statusId;
  final String bank;
  final String outlet;
  final String accountHolder;
  final String remark;
  final String requestDate;
  final String? approvalDate;
  final String group;

  WalletTransaction({
    required this.id,
    required this.transactionId,
    this.liveId,
    required this.amount,
    required this.transactionCharges,
    required this.status,
    required this.statusId,
    required this.bank,
    required this.outlet,
    required this.accountHolder,
    required this.remark,
    required this.requestDate,
    this.approvalDate,
    required this.group,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      liveId: json['live_id'],
      amount: json['amount']?.toString() ?? '0.00',
      transactionCharges: json['transaction_charges']?.toString() ?? '0.00',
      status: json['status'] ?? '',
      statusId: json['status_id'] ?? 0,
      bank: json['bank'] ?? '',
      outlet: json['outlet'] ?? '',
      accountHolder: json['account_holder'] ?? '',
      remark: json['remark'] ?? '',
      requestDate: json['request_date'] ?? '',
      approvalDate: json['approval_date'],
      group: json['group'] ?? '',
    );
  }
}

class WalletHistoryResponse {
  final bool success;
  final List<WalletTransaction> transactions;
  final int totalCount;
  final int returnedCount;
  final Map<String, int> statusSummary;
  final String currentBalance;
  final Map<String, dynamic>? filtersApplied;

  WalletHistoryResponse({
    required this.success,
    required this.transactions,
    required this.totalCount,
    required this.returnedCount,
    required this.statusSummary,
    required this.currentBalance,
    this.filtersApplied,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) {
    final statusSummary = <String, int>{};
    if (json['status_summary'] != null) {
      (json['status_summary'] as Map<String, dynamic>).forEach((key, value) {
        statusSummary[key] = value is int ? value : int.tryParse(value.toString()) ?? 0;
      });
    }

    return WalletHistoryResponse(
      success: json['success'] ?? false,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => WalletTransaction.fromJson(e))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      statusSummary: statusSummary,
      currentBalance: json['current_balance']?.toString() ?? '0.00',
      filtersApplied: json['filters_applied'],
    );
  }
}

// QR Code Transfer Models
class QRCodeResponse {
  final bool success;
  final String qrData;
  final String? qrImageUrl;
  final int userId;
  final String userName;
  final String userPhone;
  final String message;

  QRCodeResponse({
    required this.success,
    required this.qrData,
    this.qrImageUrl,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.message,
  });

  factory QRCodeResponse.fromJson(Map<String, dynamic> json) {
    return QRCodeResponse(
      success: json['success'] ?? false,
      qrData: json['qr_data']?.toString() ?? '',
      qrImageUrl: json['qr_image_url']?.toString(),
      userId: json['user_id'] ?? 0,
      userName: json['user_name']?.toString() ?? '',
      userPhone: json['user_phone']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class RecipientInfo {
  final int userId;
  final String userName;
  final String phone;
  final int walletId;
  final bool isActive;
  final bool canReceive;

  RecipientInfo({
    required this.userId,
    required this.userName,
    required this.phone,
    required this.walletId,
    required this.isActive,
    required this.canReceive,
  });

  factory RecipientInfo.fromJson(Map<String, dynamic> json) {
    return RecipientInfo(
      userId: json['user_id'] ?? 0,
      userName: json['user_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      walletId: json['wallet_id'] ?? 0,
      isActive: json['is_active'] ?? true,
      canReceive: json['can_receive'] ?? true,
    );
  }
}

class ValidateQRResponse {
  final bool success;
  final bool valid;
  final RecipientInfo? recipient;
  final String message;
  final String? error;

  ValidateQRResponse({
    required this.success,
    required this.valid,
    this.recipient,
    required this.message,
    this.error,
  });

  factory ValidateQRResponse.fromJson(Map<String, dynamic> json) {
    return ValidateQRResponse(
      success: json['success'] ?? false,
      valid: json['valid'] ?? false,
      recipient: json['recipient'] != null
          ? RecipientInfo.fromJson(json['recipient'])
          : null,
      message: json['message']?.toString() ?? '',
      error: json['error']?.toString(),
    );
  }
}

class TransferMoneyResponse {
  final bool success;
  final String transactionId;
  final TransferUserInfo sender;
  final TransferUserInfo recipient;
  final String amount;
  final String status;
  final String transactionType;
  final String createdAt;
  final String message;

  TransferMoneyResponse({
    required this.success,
    required this.transactionId,
    required this.sender,
    required this.recipient,
    required this.amount,
    required this.status,
    required this.transactionType,
    required this.createdAt,
    required this.message,
  });

  factory TransferMoneyResponse.fromJson(Map<String, dynamic> json) {
    return TransferMoneyResponse(
      success: json['success'] ?? false,
      transactionId: json['transaction_id']?.toString() ?? '',
      sender: TransferUserInfo.fromJson(json['sender'] ?? {}),
      recipient: TransferUserInfo.fromJson(json['recipient'] ?? {}),
      amount: json['amount']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? 'SUCCESS',
      transactionType: json['transaction_type']?.toString() ?? 'P2P_TRANSFER',
      createdAt: json['created_at']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class TransferUserInfo {
  final int userId;
  final String userName;
  final String oldBalance;
  final String newBalance;

  TransferUserInfo({
    required this.userId,
    required this.userName,
    required this.oldBalance,
    required this.newBalance,
  });

  factory TransferUserInfo.fromJson(Map<String, dynamic> json) {
    return TransferUserInfo(
      userId: json['user_id'] ?? 0,
      userName: json['user_name']?.toString() ?? '',
      oldBalance: json['old_balance']?.toString() ?? '0.00',
      newBalance: json['new_balance']?.toString() ?? '0.00',
    );
  }
}

class TransferTransaction {
  final String transactionId;
  final String type; // "sent" or "received"
  final String amount;
  final TransferPartyInfo recipient;
  final TransferPartyInfo sender;
  final String status;
  final String remarks;
  final String createdAt;

  TransferTransaction({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.recipient,
    required this.sender,
    required this.status,
    required this.remarks,
    required this.createdAt,
  });

  factory TransferTransaction.fromJson(Map<String, dynamic> json) {
    return TransferTransaction(
      transactionId: json['transaction_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'sent',
      amount: json['amount']?.toString() ?? '0.00',
      recipient: TransferPartyInfo.fromJson(json['recipient'] ?? {}),
      sender: TransferPartyInfo.fromJson(json['sender'] ?? {}),
      status: json['status']?.toString() ?? 'SUCCESS',
      remarks: json['remarks']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class TransferPartyInfo {
  final int userId;
  final String userName;
  final String phone;

  TransferPartyInfo({
    required this.userId,
    required this.userName,
    required this.phone,
  });

  factory TransferPartyInfo.fromJson(Map<String, dynamic> json) {
    return TransferPartyInfo(
      userId: json['user_id'] ?? 0,
      userName: json['user_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class TransferHistoryResponse {
  final bool success;
  final List<TransferTransaction> transactions;
  final int totalCount;
  final String sentTotal;
  final String receivedTotal;

  TransferHistoryResponse({
    required this.success,
    required this.transactions,
    required this.totalCount,
    required this.sentTotal,
    required this.receivedTotal,
  });

  factory TransferHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransferHistoryResponse(
      success: json['success'] ?? false,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => TransferTransaction.fromJson(e))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      sentTotal: json['sent_total']?.toString() ?? '0.00',
      receivedTotal: json['received_total']?.toString() ?? '0.00',
    );
  }
}

