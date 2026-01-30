import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Recharge Report Events
class FetchRechargeReport extends ReportsEvent {
  final int? operatorType;
  final int? operator;
  final int? status;
  final int? criteria;
  final String? search;
  final String? startDate;
  final String? endDate;
  final int? limit;
  final bool usePost;

  FetchRechargeReport({
    this.operatorType,
    this.operator,
    this.status,
    this.criteria,
    this.search,
    this.startDate,
    this.endDate,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        operatorType ?? 0,
        operator ?? 0,
        status ?? 0,
        criteria ?? 0,
        search ?? '',
        startDate ?? '',
        endDate ?? '',
        limit ?? 0,
        usePost,
      ];
}

// Ledger Report Events
class FetchLedgerReport extends ReportsEvent {
  final String? startDate;
  final String? endDate;
  final String? transactionId;
  final int? limit;
  final bool usePost;

  FetchLedgerReport({
    this.startDate,
    this.endDate,
    this.transactionId,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        startDate ?? '',
        endDate ?? '',
        transactionId ?? '',
        limit ?? 0,
        usePost,
      ];
}

// Fund Order Report Events
class FetchFundOrderReport extends ReportsEvent {
  final int? status;
  final int? transferMode;
  final int? criteria;
  final String? search;
  final String? fromDate;
  final String? toDate;
  final int? limit;
  final bool usePost;

  FetchFundOrderReport({
    this.status,
    this.transferMode,
    this.criteria,
    this.search,
    this.fromDate,
    this.toDate,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        status ?? 0,
        transferMode ?? 0,
        criteria ?? 0,
        search ?? '',
        fromDate ?? '',
        toDate ?? '',
        limit ?? 0,
        usePost,
      ];
}

// Complaint Report Events
class FetchComplaintReport extends ReportsEvent {
  final String? refundStatus;
  final int? operator;
  final int? status;
  final int? api;
  final String? search;
  final String? startDate;
  final String? endDate;
  final int? limit;
  final bool usePost;

  FetchComplaintReport({
    this.refundStatus,
    this.operator,
    this.status,
    this.api,
    this.search,
    this.startDate,
    this.endDate,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        refundStatus ?? '',
        operator ?? 0,
        status ?? 0,
        api ?? 0,
        search ?? '',
        startDate ?? '',
        endDate ?? '',
        limit ?? 0,
        usePost,
      ];
}

// Fund Debit Credit Report Events
class FetchFundDebitCreditReport extends ReportsEvent {
  final int? walletType;
  final bool? isSelf;
  final int? receivedBy;
  final String? type;
  final String? mobile;
  final String? startDate;
  final String? endDate;
  final int? limit;
  final bool usePost;

  FetchFundDebitCreditReport({
    this.walletType,
    this.isSelf,
    this.receivedBy,
    this.type,
    this.mobile,
    this.startDate,
    this.endDate,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        walletType ?? 0,
        isSelf ?? false,
        receivedBy ?? 0,
        type ?? '',
        mobile ?? '',
        startDate ?? '',
        endDate ?? '',
        limit ?? 0,
        usePost,
      ];
}

// User Daybook Report Events
class FetchUserDaybookReport extends ReportsEvent {
  final String? phoneNumber;
  final String? startDate;
  final String? endDate;
  final dynamic operator;
  final bool? isDmt;
  final int? limit;
  final bool usePost;

  FetchUserDaybookReport({
    this.phoneNumber,
    this.startDate,
    this.endDate,
    this.operator,
    this.isDmt,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        phoneNumber ?? '',
        startDate ?? '',
        endDate ?? '',
        operator?.toString() ?? '',
        isDmt ?? false,
        limit ?? 0,
        usePost,
      ];
}

// Commission Slab Report Events
class FetchCommissionSlabReport extends ReportsEvent {
  final String? commissionId;
  final int? operatorId;
  final String? operatorType;
  final String? search;
  final int? limit;
  final bool usePost;

  FetchCommissionSlabReport({
    this.commissionId,
    this.operatorId,
    this.operatorType,
    this.search,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        commissionId ?? '',
        operatorId ?? 0,
        operatorType ?? '',
        search ?? '',
        limit ?? 0,
        usePost,
      ];
}

// W2R Report Events
class FetchW2RReport extends ReportsEvent {
  final String? status;
  final String? transactionId;
  final String? startDate;
  final String? endDate;
  final int? limit;
  final bool usePost;

  FetchW2RReport({
    this.status,
    this.transactionId,
    this.startDate,
    this.endDate,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        status ?? '',
        transactionId ?? '',
        startDate ?? '',
        endDate ?? '',
        limit ?? 0,
        usePost,
      ];
}

// Daybook DMT Report Events
class FetchDaybookDMTReport extends ReportsEvent {
  final String? phoneNumber;
  final String? startDate;
  final String? endDate;
  final dynamic operator;
  final int? limit;
  final bool usePost;

  FetchDaybookDMTReport({
    this.phoneNumber,
    this.startDate,
    this.endDate,
    this.operator,
    this.limit,
    this.usePost = false,
  });

  @override
  List<Object> get props => [
        phoneNumber ?? '',
        startDate ?? '',
        endDate ?? '',
        operator?.toString() ?? '',
        limit ?? 0,
        usePost,
      ];
}

