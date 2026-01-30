class FundRequestFormDataResponse {
  final bool success;
  final FundRequestFormData data;

  FundRequestFormDataResponse({
    required this.success,
    required this.data,
  });

  factory FundRequestFormDataResponse.fromJson(Map<String, dynamic> json) {
    return FundRequestFormDataResponse(
      success: json['success'] ?? false,
      data: FundRequestFormData.fromJson(json['data'] ?? {}),
    );
  }
}

class FundRequestFormData {
  final List<Bank> banks;
  final List<TransferMode> transferModes;
  final List<WalletType> walletTypes;

  FundRequestFormData({
    required this.banks,
    required this.transferModes,
    required this.walletTypes,
  });

  factory FundRequestFormData.fromJson(Map<String, dynamic> json) {
    return FundRequestFormData(
      banks: (json['banks'] as List<dynamic>?)
              ?.map((b) => Bank.fromJson(b))
              .toList() ??
          [],
      transferModes: (json['transfer_modes'] as List<dynamic>?)
              ?.map((t) => TransferMode.fromJson(t))
              .toList() ??
          [],
      walletTypes: (json['wallet_types'] as List<dynamic>?)
              ?.map((w) => WalletType.fromJson(w))
              .toList() ??
          [],
    );
  }
}

class Bank {
  final int id;
  final String bankName;
  final String branchName;
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  final String? bankLogo;
  final String? bankQr;
  final bool isQrEnable;
  final List<PaymentCommission> paymentCommissions;

  Bank({
    required this.id,
    required this.bankName,
    required this.branchName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
    this.bankLogo,
    this.bankQr,
    required this.isQrEnable,
    required this.paymentCommissions,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      branchName: json['branch_name'] ?? '',
      accountHolder: json['account_holder'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      bankLogo: json['bank_logo'],
      bankQr: json['bank_qr'],
      isQrEnable: json['is_qr_enable'] ?? false,
      paymentCommissions: (json['payment_commissions'] as List<dynamic>?)
                      ?.map((p) => PaymentCommission.fromJson(p))
                      .toList() ??
                  [],
    );
  }
}

class PaymentCommission {
  final String mode;
  final bool enabled;
  final double amount;
  final String type; // "P" for Percentage, "F" for Fixed

  PaymentCommission({
    required this.mode,
    required this.enabled,
    required this.amount,
    required this.type,
  });

  factory PaymentCommission.fromJson(Map<String, dynamic> json) {
    return PaymentCommission(
      mode: json['mode'] ?? '',
      enabled: json['enabled'] ?? false,
      amount: (json['amount'] is num) ? json['amount'].toDouble() : 0.0,
      type: json['type'] ?? 'F',
    );
  }
}

class TransferMode {
  final int id;
  final String name;

  TransferMode({
    required this.id,
    required this.name,
  });

  factory TransferMode.fromJson(Map<String, dynamic> json) {
    return TransferMode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class WalletType {
  final int id;
  final String name;

  WalletType({
    required this.id,
    required this.name,
  });

  factory WalletType.fromJson(Map<String, dynamic> json) {
    return WalletType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class BankDetailsResponse {
  final bool success;
  final Bank bank;

  BankDetailsResponse({
    required this.success,
    required this.bank,
  });

  factory BankDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BankDetailsResponse(
      success: json['success'] ?? false,
      bank: Bank.fromJson(json['bank'] ?? {}),
    );
  }
}

class FundRequestSubmitResponse {
  final bool success;
  final String message;
  final FundRequest fundRequest;

  FundRequestSubmitResponse({
    required this.success,
    required this.message,
    required this.fundRequest,
  });

  factory FundRequestSubmitResponse.fromJson(Map<String, dynamic> json) {
    return FundRequestSubmitResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      fundRequest: FundRequest.fromJson(json['fund_request'] ?? {}),
    );
  }
}

class FundRequestHistoryResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<FundRequest> fundRequests;

  FundRequestHistoryResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.fundRequests,
  });

  factory FundRequestHistoryResponse.fromJson(Map<String, dynamic> json) {
    return FundRequestHistoryResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      fundRequests: (json['fund_requests'] as List<dynamic>?)
              ?.map((f) => FundRequest.fromJson(f))
              .toList() ??
          [],
    );
  }
}

class FundRequestDetailsResponse {
  final bool success;
  final FundRequest fundRequest;

  FundRequestDetailsResponse({
    required this.success,
    required this.fundRequest,
  });

  factory FundRequestDetailsResponse.fromJson(Map<String, dynamic> json) {
    return FundRequestDetailsResponse(
      success: json['success'] ?? false,
      fundRequest: FundRequest.fromJson(json['fund_request'] ?? {}),
    );
  }
}

class FundRequest {
  final int id;
  final String transactionId;
  final String amount;
  final String status; // PENDING, APPROVED, REJECTED
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  final String branch;
  final String transferMode;
  final int? transferModeId;
  final String walletType;
  final int? walletTypeId;
  final String? mobileNo;
  final String? remark;
  final String? receiptUrl;
  final String entryDate;

  FundRequest({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.status,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
    required this.branch,
    required this.transferMode,
    this.transferModeId,
    required this.walletType,
    this.walletTypeId,
    this.mobileNo,
    this.remark,
    this.receiptUrl,
    required this.entryDate,
  });

  factory FundRequest.fromJson(Map<String, dynamic> json) {
    return FundRequest(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      amount: json['amount'] ?? '0.00',
      status: json['status'] ?? 'PENDING',
      bankName: json['bank_name'] ?? '',
      accountHolder: json['account_holder'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      branch: json['branch'] ?? '',
      transferMode: json['transfer_mode'] ?? '',
      transferModeId: json['transfer_mode_id'],
      walletType: json['wallet_type'] ?? '',
      walletTypeId: json['wallet_type_id'],
      mobileNo: json['mobile_no'],
      remark: json['remark'],
      receiptUrl: json['receipt_url'],
      entryDate: json['entry_date'] ?? '',
    );
  }
}

