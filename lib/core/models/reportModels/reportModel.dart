// Report Models for all report types

class RechargeTransaction {
  final int id;
  final String transactionId;
  final String outlet;
  final String accountNo;
  final String operatorName;
  final String amount;
  final String apiName;
  final String datetime;
  final String? liveid;
  final String statusName;
  final int statusId;
  final String? refundStatus; // null, "UNDER_REVIEW", "REFUNDED", "REJECTED", "DISPUTE"
  final String? refundStatusDisplay; // Human-readable display name for refund_status
  final bool? disputeRequested; // Indicates if dispute was requested
  final bool? w2rAllowed; // Whether W2R is allowed for this transaction
  final String? w2rStatus; // null, "REQUESTED", "ACCEPTED", "REJECTED"
  final String? w2rRightAccountNo; // Right account number if W2R is accepted

  RechargeTransaction({
    required this.id,
    required this.transactionId,
    required this.outlet,
    required this.accountNo,
    required this.operatorName,
    required this.amount,
    required this.apiName,
    required this.datetime,
    this.liveid,
    required this.statusName,
    required this.statusId,
    this.refundStatus,
    this.refundStatusDisplay,
    this.disputeRequested,
    this.w2rAllowed,
    this.w2rStatus,
    this.w2rRightAccountNo,
  });

  factory RechargeTransaction.fromJson(Map<String, dynamic> json) {
    return RechargeTransaction(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? json['txn_id'] ?? '',
      outlet: json['outlet'] ?? '',
      accountNo: json['account_no'] ?? '',
      operatorName: json['operator_name'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      apiName: json['api_name'] ?? '',
      datetime: json['datetime'] ?? '',
      liveid: json['liveid'] ?? json['live_id'],
      statusName: json['status_name'] ?? '',
      statusId: json['status_id'] ?? 0,
      refundStatus: json['refund_status'],
      refundStatusDisplay: json['refund_status_display'],
      disputeRequested: json['dispute_requested'] is bool
          ? json['dispute_requested']
          : json['dispute_requested']?.toString().toLowerCase() == 'true',
      w2rAllowed: json['w2r_allowed'] is bool
          ? json['w2r_allowed']
          : json['w2r_allowed']?.toString().toLowerCase() == 'true',
      w2rStatus: json['w2r_status'],
      w2rRightAccountNo: json['w2r_right_account_no'],
    );
  }
}

class RechargeReportResponse {
  final bool success;
  final List<RechargeTransaction> transactions;
  final int totalCount;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? appliedFilters;

  RechargeReportResponse({
    required this.success,
    required this.transactions,
    required this.totalCount,
    this.filters,
    this.appliedFilters,
  });

  factory RechargeReportResponse.fromJson(Map<String, dynamic> json) {
    return RechargeReportResponse(
      success: json['success'] ?? false,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => RechargeTransaction.fromJson(e))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      filters: json['filters'],
      appliedFilters: json['applied_filters'],
    );
  }
}

class LedgerTransaction {
  final int id;
  final Map<String, dynamic>? user;
  final String transactionId;
  final String transactionName; // New field from backend
  final String transactionType; // "credit" or "debit"
  final double amount; // Positive for credit, negative for debit
  final double balanceAfter; // Balance after transaction
  final String dateTime;
  final Map<String, dynamic>? dateTimeFormatted;
  final String description;
  final String oldBalance;
  final String credit;
  final String debit;
  final String currentBalance;
  final String remark;

  LedgerTransaction({
    required this.id,
    this.user,
    required this.transactionId,
    required this.transactionName,
    required this.transactionType,
    required this.amount,
    required this.balanceAfter,
    required this.dateTime,
    this.dateTimeFormatted,
    required this.description,
    required this.oldBalance,
    required this.credit,
    required this.debit,
    required this.currentBalance,
    required this.remark,
  });

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    // Determine transaction type
    final creditValue = double.tryParse(json['credit']?.toString() ?? '0') ?? 0;
    final debitValue = double.tryParse(json['debit']?.toString() ?? '0') ?? 0;
    final isCredit = creditValue > 0;
    
    // Get amount - prefer 'amount' field, fallback to credit/debit
    double amountValue = 0;
    if (json['amount'] != null) {
      amountValue = (json['amount'] is num) 
          ? json['amount'].toDouble() 
          : double.tryParse(json['amount'].toString()) ?? (isCredit ? creditValue : -debitValue);
    } else {
      amountValue = isCredit ? creditValue : -debitValue;
    }
    
    // Get balance after - prefer 'balance_after', fallback to 'current_balance'
    double balanceAfterValue = 0;
    if (json['balance_after'] != null) {
      balanceAfterValue = (json['balance_after'] is num)
          ? json['balance_after'].toDouble()
          : double.tryParse(json['balance_after'].toString()) ?? 0;
    } else {
      balanceAfterValue = double.tryParse(json['current_balance']?.toString() ?? '0') ?? 0;
    }
    
    return LedgerTransaction(
      id: json['id'] ?? 0,
      user: json['user'],
      transactionId: json['transaction_id'] ?? '',
      transactionName: json['transaction_name']?.toString() ?? json['description']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? (isCredit ? 'credit' : 'debit'),
      amount: amountValue,
      balanceAfter: balanceAfterValue,
      dateTime: json['datetime']?.toString() ?? json['date_time']?.toString() ?? '',
      dateTimeFormatted: json['date_time_formatted'],
      description: json['description']?.toString() ?? '',
      oldBalance: json['old_balance']?.toString() ?? '0.00',
      credit: json['credit']?.toString() ?? '0.00',
      debit: json['debit']?.toString() ?? '0.00',
      currentBalance: json['current_balance']?.toString() ?? '0.00',
      remark: json['remark']?.toString() ?? '',
    );
  }
}

class LedgerReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<LedgerTransaction> data;

  LedgerReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory LedgerReportResponse.fromJson(Map<String, dynamic> json) {
    return LedgerReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => LedgerTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class FundOrderTransaction {
  final int id;
  final String transactionId;
  final int user;
  final String userName;
  final int walletType;
  final String walletTypeName;
  final int status;
  final String statusName;
  final int transferMode;
  final String transferModeName;
  final String accountHolder;
  final String bank;
  final String mobile;
  final String amount;
  final String transactionCharges;
  final String requestDate;
  final String? approvalDate;
  final String remark;

  FundOrderTransaction({
    required this.id,
    required this.transactionId,
    required this.user,
    required this.userName,
    required this.walletType,
    required this.walletTypeName,
    required this.status,
    required this.statusName,
    required this.transferMode,
    required this.transferModeName,
    required this.accountHolder,
    required this.bank,
    required this.mobile,
    required this.amount,
    required this.transactionCharges,
    required this.requestDate,
    this.approvalDate,
    required this.remark,
  });

  factory FundOrderTransaction.fromJson(Map<String, dynamic> json) {
    return FundOrderTransaction(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      user: json['user'] ?? 0,
      userName: json['user_name'] ?? '',
      walletType: json['wallet_type'] ?? 0,
      walletTypeName: json['wallet_type_name'] ?? '',
      status: json['status'] ?? 0,
      statusName: json['status_name'] ?? '',
      transferMode: json['transfer_mode'] ?? 0,
      transferModeName: json['transfer_mode_name'] ?? '',
      accountHolder: json['account_holder'] ?? '',
      bank: json['bank'] ?? '',
      mobile: json['mobile'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      transactionCharges: json['transaction_charges']?.toString() ?? '0.00',
      requestDate: json['request_date'] ?? '',
      approvalDate: json['approval_date'],
      remark: json['remark'] ?? '',
    );
  }
}

class FundOrderReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<FundOrderTransaction> data;

  FundOrderReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory FundOrderReportResponse.fromJson(Map<String, dynamic> json) {
    return FundOrderReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => FundOrderTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ComplaintTransaction {
  final int id;
  final String user;
  final String transactionId;
  final String rechargeDate;
  final String requestDate;
  final String? acceptRejectDate;
  final String accountNo;
  final String amount;
  final String operator;
  final String status;
  final String refundStatus;
  final String refundStatusDisplay;
  final String api;

  ComplaintTransaction({
    required this.id,
    required this.user,
    required this.transactionId,
    required this.rechargeDate,
    required this.requestDate,
    this.acceptRejectDate,
    required this.accountNo,
    required this.amount,
    required this.operator,
    required this.status,
    required this.refundStatus,
    required this.refundStatusDisplay,
    required this.api,
  });

  factory ComplaintTransaction.fromJson(Map<String, dynamic> json) {
    return ComplaintTransaction(
      id: json['id'] ?? 0,
      user: json['user'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      rechargeDate: json['recharge_date'] ?? '',
      requestDate: json['request_date'] ?? '',
      acceptRejectDate: json['accept_reject_date'],
      accountNo: json['account_no'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      operator: json['operator'] ?? '',
      status: json['status'] ?? '',
      refundStatus: json['refund_status'] ?? '',
      refundStatusDisplay: json['refund_status_display'] ?? '',
      api: json['api'] ?? '',
    );
  }
}

class ComplaintReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<ComplaintTransaction> data;

  ComplaintReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory ComplaintReportResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ComplaintTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class FundDebitCreditTransaction {
  final int id;
  final String user;
  final int walletType;
  final String walletTypeName;
  final String entryDate;
  final String datetime;
  final double amount; // Can be positive (credit) or negative (debit)
  final String transactionType; // "credit" or "debit"
  final String debitCreditType; // "credit" or "debit"
  final double balanceAfter; // Balance after transaction
  final String transactionId;
  final String transactionName;
  final String description;
  final bool isSelf;
  final String mobile;
  final int? receivedBy;
  final String service;
  final String remark;
  final String currentBalance;
  final String receipt;

  FundDebitCreditTransaction({
    required this.id,
    required this.user,
    required this.walletType,
    required this.walletTypeName,
    required this.entryDate,
    required this.datetime,
    required this.amount,
    required this.transactionType,
    required this.debitCreditType,
    required this.balanceAfter,
    required this.transactionId,
    required this.transactionName,
    required this.description,
    required this.isSelf,
    required this.mobile,
    this.receivedBy,
    required this.service,
    required this.remark,
    required this.currentBalance,
    required this.receipt,
  });

  factory FundDebitCreditTransaction.fromJson(Map<String, dynamic> json) {
    // Determine transaction type - prefer transaction_type, fallback to debit_credit_type, then amount sign
    String transactionTypeValue = json['transaction_type']?.toString().toLowerCase() ?? 
                                  json['debit_credit_type']?.toString().toLowerCase() ?? 
                                  '';
    
    // Get amount - can be positive or negative
    double amountValue = 0;
    if (json['amount'] != null) {
      amountValue = (json['amount'] is num) 
          ? json['amount'].toDouble() 
          : double.tryParse(json['amount'].toString()) ?? 0;
    }
    
    // If transaction_type is not set, determine from amount sign
    if (transactionTypeValue.isEmpty) {
      transactionTypeValue = amountValue >= 0 ? 'credit' : 'debit';
    }
    
    // Get balance after
    double balanceAfterValue = 0;
    if (json['balance_after'] != null) {
      balanceAfterValue = (json['balance_after'] is num)
          ? json['balance_after'].toDouble()
          : double.tryParse(json['balance_after'].toString()) ?? 0;
    } else if (json['current_balance'] != null) {
      balanceAfterValue = (json['current_balance'] is num)
          ? json['current_balance'].toDouble()
          : double.tryParse(json['current_balance'].toString()) ?? 0;
    }
    
    return FundDebitCreditTransaction(
      id: json['id'] ?? 0,
      user: json['user']?.toString() ?? '',
      walletType: json['wallet_type'] ?? 0,
      walletTypeName: json['wallet_type_name']?.toString() ?? '',
      entryDate: json['entry_date']?.toString() ?? '',
      datetime: json['datetime']?.toString() ?? '',
      amount: amountValue,
      transactionType: transactionTypeValue,
      debitCreditType: json['debit_credit_type']?.toString().toLowerCase() ?? transactionTypeValue,
      balanceAfter: balanceAfterValue,
      transactionId: json['transaction_id']?.toString() ?? json['receipt']?.toString() ?? '',
      transactionName: json['transaction_name']?.toString() ?? json['description']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isSelf: json['is_self'] ?? false,
      mobile: json['mobile']?.toString() ?? '',
      receivedBy: json['received_by'],
      service: json['service']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      currentBalance: json['current_balance']?.toString() ?? '0.00',
      receipt: json['receipt']?.toString() ?? '',
    );
  }
}

class FundDebitCreditReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<FundDebitCreditTransaction> data;

  FundDebitCreditReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory FundDebitCreditReportResponse.fromJson(Map<String, dynamic> json) {
    return FundDebitCreditReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => FundDebitCreditTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UserDaybookEntry {
  final int id;
  final String user;
  final String operatorName;
  final String apiName;
  final String dateTime;
  final int totalHits;
  final String totalAmount;
  final int successHits;
  final String successAmount;
  final int failedHits;
  final String failedAmount;
  final int pendingHits;
  final String pendingAmount;
  final String directCommission;
  final String directIncentive;

  UserDaybookEntry({
    required this.id,
    required this.user,
    required this.operatorName,
    required this.apiName,
    required this.dateTime,
    required this.totalHits,
    required this.totalAmount,
    required this.successHits,
    required this.successAmount,
    required this.failedHits,
    required this.failedAmount,
    required this.pendingHits,
    required this.pendingAmount,
    required this.directCommission,
    required this.directIncentive,
  });

  factory UserDaybookEntry.fromJson(Map<String, dynamic> json) {
    return UserDaybookEntry(
      id: json['id'] ?? 0,
      user: json['user'] ?? '',
      operatorName: json['operator_name'] ?? '',
      apiName: json['api_name'] ?? '',
      dateTime: json['date_time'] ?? '',
      totalHits: json['total_hits'] ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      successHits: json['success_hits'] ?? 0,
      successAmount: json['success_amount']?.toString() ?? '0.00',
      failedHits: json['failed_hits'] ?? 0,
      failedAmount: json['failed_amount']?.toString() ?? '0.00',
      pendingHits: json['pending_hits'] ?? 0,
      pendingAmount: json['pending_amount']?.toString() ?? '0.00',
      directCommission: json['direct_commission']?.toString() ?? '0.00',
      directIncentive: json['direct_incentive']?.toString() ?? '0.00',
    );
  }
}

class UserDaybookReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<UserDaybookEntry> data;

  UserDaybookReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory UserDaybookReportResponse.fromJson(Map<String, dynamic> json) {
    return UserDaybookReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => UserDaybookEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CommissionSlab {
  final int id;
  final String commissionId;
  final int operatorID;
  final String operatorName;
  final String operatorType;
  final String rt;
  final int slabID;
  final String? operatorIcon;

  CommissionSlab({
    required this.id,
    required this.commissionId,
    required this.operatorID,
    required this.operatorName,
    required this.operatorType,
    required this.rt,
    required this.slabID,
    this.operatorIcon,
  });

  factory CommissionSlab.fromJson(Map<String, dynamic> json) {
    // Safely convert commissionId (might be int or String)
    String commissionId;
    final commissionIdValue = json['commissionId'];
    if (commissionIdValue == null) {
      commissionId = '';
    } else if (commissionIdValue is int) {
      commissionId = commissionIdValue.toString();
    } else if (commissionIdValue is String) {
      commissionId = commissionIdValue;
    } else {
      commissionId = commissionIdValue.toString();
    }
    
    // Safely convert operatorName (might be int or String)
    String operatorName;
    final operatorNameValue = json['operatorName'];
    if (operatorNameValue == null) {
      operatorName = '';
    } else if (operatorNameValue is int) {
      operatorName = operatorNameValue.toString();
    } else if (operatorNameValue is String) {
      operatorName = operatorNameValue;
    } else {
      operatorName = operatorNameValue.toString();
    }
    
    // Safely convert operatorType (might be int or String)
    String operatorType;
    final operatorTypeValue = json['operatorType'];
    if (operatorTypeValue == null) {
      operatorType = '';
    } else if (operatorTypeValue is int) {
      operatorType = operatorTypeValue.toString();
    } else if (operatorTypeValue is String) {
      operatorType = operatorTypeValue;
    } else {
      operatorType = operatorTypeValue.toString();
    }
    
    // Safely convert rt (might be int, double, or String)
    String rt;
    final rtValue = json['rt'];
    if (rtValue == null) {
      rt = '0.00';
    } else if (rtValue is int) {
      rt = rtValue.toStringAsFixed(2);
    } else if (rtValue is double) {
      rt = rtValue.toStringAsFixed(2);
    } else {
      rt = rtValue.toString();
    }
    
    // Handle operator_icon - clean up double /media/ paths if present
    String? operatorIcon = json['operator_icon'];
    if (operatorIcon != null && operatorIcon.isNotEmpty) {
      // Fix double /media//media/ issue
      operatorIcon = operatorIcon.replaceAll('/media//media/', '/media/');
      // Ensure it starts with /media/ if it's a relative path
      if (!operatorIcon.startsWith('http') && !operatorIcon.startsWith('/media/')) {
        operatorIcon = '/media/$operatorIcon';
      }
    }
    
    return CommissionSlab(
      id: json['id'] ?? 0,
      commissionId: commissionId,
      operatorID: json['operatorID'] ?? 0,
      operatorName: operatorName,
      operatorType: operatorType,
      rt: rt,
      slabID: json['slabID'] ?? 0,
      operatorIcon: operatorIcon,
    );
  }
}

class CommissionSlabReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<CommissionSlab> data;

  CommissionSlabReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory CommissionSlabReportResponse.fromJson(Map<String, dynamic> json) {
    return CommissionSlabReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CommissionSlab.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class W2RTransaction {
  final int id;
  final String transactionId;
  final String originalAccountNo;
  final String rightAccountNo;
  final String status;
  final String statusDisplay;
  final String adminTransactionId;
  final String remarks;
  final String createdAt;
  final String updatedAt;
  final String? statusUpdatedAt;

  W2RTransaction({
    required this.id,
    required this.transactionId,
    required this.originalAccountNo,
    required this.rightAccountNo,
    required this.status,
    required this.statusDisplay,
    required this.adminTransactionId,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.statusUpdatedAt,
  });

  factory W2RTransaction.fromJson(Map<String, dynamic> json) {
    return W2RTransaction(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      originalAccountNo: json['original_account_no'] ?? '',
      rightAccountNo: json['right_account_no'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      adminTransactionId: json['admin_transaction_id'] ?? '',
      remarks: json['remarks'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      statusUpdatedAt: json['status_updated_at'],
    );
  }
}

class W2RReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<W2RTransaction> data;

  W2RReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory W2RReportResponse.fromJson(Map<String, dynamic> json) {
    return W2RReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => W2RTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DaybookDMTReportResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<UserDaybookEntry> data;
  final String reportType;

  DaybookDMTReportResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
    required this.reportType,
  });

  factory DaybookDMTReportResponse.fromJson(Map<String, dynamic> json) {
    return DaybookDMTReportResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => UserDaybookEntry.fromJson(e))
              .toList() ??
          [],
      reportType: json['report_type'] ?? 'DMT',
    );
  }
}

