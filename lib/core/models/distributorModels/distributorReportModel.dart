// User Ledger Models
class UserLedgerResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<LedgerEntry> data;

  UserLedgerResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory UserLedgerResponse.fromJson(Map<String, dynamic> json) {
    return UserLedgerResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LedgerEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class LedgerEntry {
  final int id;
  final String transactionId;
  final String dateTime;
  final DateTimeFormatted? dateTimeFormatted;
  final String? description;
  final double credit;
  final double debited;
  final LedgerUser? user;

  LedgerEntry({
    required this.id,
    required this.transactionId,
    required this.dateTime,
    this.dateTimeFormatted,
    this.description,
    required this.credit,
    required this.debited,
    this.user,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      dateTime: json['date_time'] ?? '',
      dateTimeFormatted: json['date_time_formatted'] != null
          ? DateTimeFormatted.fromJson(json['date_time_formatted'])
          : null,
      description: json['description'],
      credit: (json['credit'] is int)
          ? (json['credit'] as int).toDouble()
          : (json['credit'] is double)
          ? json['credit']
          : double.tryParse(json['credit'].toString()) ?? 0.0,
      debited: (json['debited'] is int)
          ? (json['debited'] as int).toDouble()
          : (json['debited'] is double)
          ? json['debited']
          : double.tryParse(json['debited'].toString()) ?? 0.0,
      user: json['user'] != null ? LedgerUser.fromJson(json['user']) : null,
    );
  }
}

class DateTimeFormatted {
  final String date;
  final String time;

  DateTimeFormatted({required this.date, required this.time});

  factory DateTimeFormatted.fromJson(Map<String, dynamic> json) {
    return DateTimeFormatted(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class LedgerUser {
  final String username;
  final String? phoneNumber;
  final String? role;

  LedgerUser({required this.username, this.phoneNumber, this.role});

  factory LedgerUser.fromJson(Map<String, dynamic> json) {
    return LedgerUser(
      username: json['username'] ?? '',
      phoneNumber: json['phone_number'],
      role: json['role'],
    );
  }
}

// User Daybook Models
class UserDaybookResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<DaybookEntry> data;

  UserDaybookResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory UserDaybookResponse.fromJson(Map<String, dynamic> json) {
    return UserDaybookResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => DaybookEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DaybookEntry {
  final int id;
  final String dateTime;
  final int totalHits;
  final int successHits;
  final int failedHits;
  final double totalAmount;
  final double successAmount;
  final DaybookUser? user;
  final DaybookOperator? operator;

  DaybookEntry({
    required this.id,
    required this.dateTime,
    required this.totalHits,
    required this.successHits,
    required this.failedHits,
    required this.totalAmount,
    required this.successAmount,
    this.user,
    this.operator,
  });

  factory DaybookEntry.fromJson(Map<String, dynamic> json) {
    return DaybookEntry(
      id: json['id'] ?? 0,
      dateTime: json['date_time'] ?? json['date'] ?? '',
      totalHits: json['total_hits'] ?? 0,
      successHits: json['success_hits'] ?? 0,
      failedHits: json['failed_hits'] ?? 0,
      totalAmount: (json['total_amount'] is int)
          ? (json['total_amount'] as int).toDouble()
          : (json['total_amount'] is double)
          ? json['total_amount']
          : double.tryParse(json['total_amount'].toString()) ?? 0.0,
      successAmount: (json['success_amount'] is int)
          ? (json['success_amount'] as int).toDouble()
          : (json['success_amount'] is double)
          ? json['success_amount']
          : double.tryParse(json['success_amount'].toString()) ?? 0.0,
      user: json['user'] != null ? DaybookUser.fromJson(json['user']) : null,
      operator: json['operator'] != null
          ? DaybookOperator.fromJson(json['operator'])
          : null,
    );
  }
}

class DaybookUser {
  final String username;
  final String? phoneNumber;

  DaybookUser({required this.username, this.phoneNumber});

  factory DaybookUser.fromJson(Map<String, dynamic> json) {
    return DaybookUser(
      username: json['username'] ?? '',
      phoneNumber: json['phone_number'],
    );
  }
}

class DaybookOperator {
  final int operatorID;
  final String operatorName;

  DaybookOperator({required this.operatorID, required this.operatorName});

  factory DaybookOperator.fromJson(Map<String, dynamic> json) {
    return DaybookOperator(
      operatorID: json['OperatorID'] ?? json['operatorID'] ?? 0,
      operatorName: json['OperatorName'] ?? json['operatorName'] ?? '',
    );
  }
}

// Fund Debit-Credit Models
class FundDebitCreditResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<FundDebitCreditEntry> data;

  FundDebitCreditResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory FundDebitCreditResponse.fromJson(Map<String, dynamic> json) {
    // Debug log
    print(
      '[DEBUG] FundDebitCreditResponse.fromJson: data type = '
      '${json['data']?.runtimeType}, value = ${json['data']}',
    );
    List<FundDebitCreditEntry> parsedData = [];
    if (json['data'] is List) {
      for (var e in json['data']) {
        if (e is Map<String, dynamic>) {
          try {
            parsedData.add(FundDebitCreditEntry.fromJson(e));
          } catch (err, stack) {
            print('[ERROR] Failed to parse FundDebitCreditEntry: $err');
            print(stack);
          }
        } else {
          print(
            '[ERROR] Skipping non-map entry in FundDebitCreditResponse.data: $e',
          );
        }
      }
    } else {
      print(
        '[ERROR] FundDebitCreditResponse.data is not a List: ${json['data']}',
      );
    }
    return FundDebitCreditResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data: parsedData,
    );
  }
}

class FundDebitCreditEntry {
  final int id;
  final String entryDate;
  final double amount;
  final String debitCreditType; // "credit" or "debit"
  final String? service;
  final FundDebitCreditWalletType? walletType;

  FundDebitCreditEntry({
    required this.id,
    required this.entryDate,
    required this.amount,
    required this.debitCreditType,
    this.service,
    this.walletType,
  });

  factory FundDebitCreditEntry.fromJson(Map<String, dynamic> json) {
    FundDebitCreditWalletType? walletTypeObj;
    if (json['wallet_type'] != null) {
      if (json['wallet_type'] is Map<String, dynamic>) {
        walletTypeObj = FundDebitCreditWalletType.fromJson(json['wallet_type']);
      } else if (json['wallet_type'] is int) {
        // Try to get name from wallet_type_name if present
        walletTypeObj = FundDebitCreditWalletType(
          id: json['wallet_type'],
          name: json['wallet_type_name']?.toString() ?? '',
        );
      } else if (json['wallet_type'] is String) {
        // Sometimes wallet_type might be a string id
        walletTypeObj = FundDebitCreditWalletType(
          id: int.tryParse(json['wallet_type']) ?? 0,
          name: json['wallet_type_name']?.toString() ?? '',
        );
      }
    }
    return FundDebitCreditEntry(
      id: json['id'] ?? 0,
      entryDate: json['entry_date'] ?? json['date_time'] ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] is double)
          ? json['amount']
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      debitCreditType: json['debit_credit_type'] ?? json['type'] ?? '',
      service: json['service'],
      walletType: walletTypeObj,
    );
  }
}

class FundDebitCreditWalletType {
  final int id;
  final String name;

  FundDebitCreditWalletType({required this.id, required this.name});

  factory FundDebitCreditWalletType.fromJson(Map<String, dynamic> json) {
    return FundDebitCreditWalletType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// Dispute Settlement Models
class DisputeSettlementResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<DisputeSettlementEntry> data;

  DisputeSettlementResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.data,
  });

  factory DisputeSettlementResponse.fromJson(Map<String, dynamic> json) {
    return DisputeSettlementResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => DisputeSettlementEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DisputeSettlementEntry {
  final int id;
  final String transactionId;
  final String requestDate;
  final String refundStatus;
  final double amount;
  final DisputeOperator? operator;
  final String? reason;

  DisputeSettlementEntry({
    required this.id,
    required this.transactionId,
    required this.requestDate,
    required this.refundStatus,
    required this.amount,
    this.operator,
    this.reason,
  });

  factory DisputeSettlementEntry.fromJson(Map<String, dynamic> json) {
    return DisputeSettlementEntry(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      requestDate: json['request_date'] ?? json['entry_date'] ?? '',
      refundStatus: json['refund_status'] ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] is double)
          ? json['amount']
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      operator: json['operator'] != null
          ? DisputeOperator.fromJson(json['operator'])
          : null,
      reason: json['reason'],
    );
  }
}

class DisputeOperator {
  final int operatorID;
  final String operatorName;

  DisputeOperator({required this.operatorID, required this.operatorName});

  factory DisputeOperator.fromJson(Map<String, dynamic> json) {
    return DisputeOperator(
      operatorID: json['OperatorID'] ?? json['operatorID'] ?? 0,
      operatorName: json['OperatorName'] ?? json['operatorName'] ?? '',
    );
  }
}
