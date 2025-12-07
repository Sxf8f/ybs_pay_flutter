class TransactionResponse {
  final bool success;
  final List<Transaction> transactions;
  final int totalCount;
  final Filters filters;
  final AppliedFilters appliedFilters;

  TransactionResponse({
    required this.success,
    required this.transactions,
    required this.totalCount,
    required this.filters,
    required this.appliedFilters,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] ?? false,
      transactions: json['transactions'] != null
          ? List<Transaction>.from(
              json['transactions'].map((x) => Transaction.fromJson(x)),
            )
          : [],
      totalCount: json['total_count'] ?? 0,
      filters: json['filters'] != null
          ? Filters.fromJson(json['filters'])
          : Filters(
              operatorTypes: [],
              operators: [],
              statuses: [],
              criteria: [],
            ),
      appliedFilters: json['applied_filters'] != null
          ? AppliedFilters.fromJson(json['applied_filters'])
          : AppliedFilters(),
    );
  }
}

class Transaction {
  final int id;
  final String datetime;
  final String statusName;
  final String operatorName;
  final String operatorImage;
  final String apiName;
  final String phoneNumber;
  final String username;
  final String transactionId;
  final String accountNo;
  final double opening;
  final double amount;
  final double debit;
  final double comm;
  final double closing;
  final String refundStatus;
  final String liveid;
  final String requestMode;
  final int user;
  final int operator;
  final int status;
  final int apiId;

  Transaction({
    required this.id,
    required this.datetime,
    required this.statusName,
    required this.operatorName,
    required this.operatorImage,
    required this.apiName,
    required this.phoneNumber,
    required this.username,
    required this.transactionId,
    required this.accountNo,
    required this.opening,
    required this.amount,
    required this.debit,
    required this.comm,
    required this.closing,
    required this.refundStatus,
    required this.liveid,
    required this.requestMode,
    required this.user,
    required this.operator,
    required this.status,
    required this.apiId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      datetime: json['datetime'] ?? '',
      statusName: json['status_name'] ?? '',
      operatorName: json['operator_name'] ?? '',
      operatorImage: json['operator_image'] ?? '',
      apiName: json['api_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      username: json['username'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      accountNo: json['account_no'] ?? '',
      opening: (json['opening'] ?? 0.0).toDouble(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      debit: (json['debit'] ?? 0.0).toDouble(),
      comm: (json['comm'] ?? 0.0).toDouble(),
      closing: (json['closing'] ?? 0.0).toDouble(),
      refundStatus: json['refund_status'] ?? '',
      liveid: json['liveid'] ?? '',
      requestMode: json['request_mode'] ?? '',
      user: json['user'] ?? 0,
      operator: json['operator'] ?? 0,
      status: json['status'] ?? 0,
      apiId: json['api_id'] ?? 0,
    );
  }
}

class Filters {
  final List<OperatorType> operatorTypes;
  final List<Operator> operators;
  final List<Status> statuses;
  final List<dynamic> criteria;

  Filters({
    required this.operatorTypes,
    required this.operators,
    required this.statuses,
    required this.criteria,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      operatorTypes: json['operator_types'] != null
          ? List<OperatorType>.from(
              json['operator_types'].map((x) => OperatorType.fromJson(x)),
            )
          : [],
      operators: json['operators'] != null
          ? List<Operator>.from(
              json['operators'].map((x) => Operator.fromJson(x)),
            )
          : [],
      statuses: json['statuses'] != null
          ? List<Status>.from(json['statuses'].map((x) => Status.fromJson(x)))
          : [],
      criteria: json['criteria'] ?? [],
    );
  }
}

class OperatorType {
  final int id;
  final String name;

  OperatorType({required this.id, required this.name});

  factory OperatorType.fromJson(Map<String, dynamic> json) {
    return OperatorType(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Operator {
  final int id;
  final String name;
  final int typeId;
  final String image;

  Operator({
    required this.id,
    required this.name,
    required this.typeId,
    required this.image,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      typeId: json['type_id'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}

class Status {
  final int id;
  final String name;

  Status({required this.id, required this.name});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class AppliedFilters {
  final int? operatorType;
  final int? operator;
  final int? status;
  final dynamic criteria;
  final String search;
  final String? startDate;
  final String? endDate;
  final int limit;

  AppliedFilters({
    this.operatorType,
    this.operator,
    this.status,
    this.criteria,
    this.search = '',
    this.startDate,
    this.endDate,
    this.limit = 50,
  });

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    // Handle operator_type - can be int or string
    int? operatorType;
    if (json['operator_type'] != null) {
      if (json['operator_type'] is int) {
        operatorType = json['operator_type'];
      } else if (json['operator_type'] is String) {
        operatorType = int.tryParse(json['operator_type']);
      }
    }

    // Handle operator - can be int or string
    int? operator;
    if (json['operator'] != null) {
      if (json['operator'] is int) {
        operator = json['operator'];
      } else if (json['operator'] is String) {
        operator = int.tryParse(json['operator']);
      }
    }

    // Handle status - can be int or string
    int? status;
    if (json['status'] != null) {
      if (json['status'] is int) {
        status = json['status'];
      } else if (json['status'] is String) {
        status = int.tryParse(json['status']);
      }
    }

    // Handle limit - can be int or string
    int limit = 50;
    if (json['limit'] != null) {
      if (json['limit'] is int) {
        limit = json['limit'];
      } else if (json['limit'] is String) {
        limit = int.tryParse(json['limit']) ?? 50;
      }
    }

    return AppliedFilters(
      operatorType: operatorType,
      operator: operator,
      status: status,
      criteria: json['criteria'],
      search: json['search'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      limit: limit,
    );
  }
}
