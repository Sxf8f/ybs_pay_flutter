import 'package:equatable/equatable.dart';

abstract class DistributorReportEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUserLedgerEvent extends DistributorReportEvent {
  final String? startDate;
  final String? endDate;
  final String? transactionId;
  final int? limit;

  FetchUserLedgerEvent({
    this.startDate,
    this.endDate,
    this.transactionId,
    this.limit,
  });

  @override
  List<Object> get props => [
        if (startDate != null) startDate!,
        if (endDate != null) endDate!,
        if (transactionId != null) transactionId!,
        if (limit != null) limit!,
      ];
}

class FetchUserDaybookEvent extends DistributorReportEvent {
  final String? phoneNumber;
  final String? startDate;
  final String? endDate;
  final String? operator;
  final int? limit;

  FetchUserDaybookEvent({
    this.phoneNumber,
    this.startDate,
    this.endDate,
    this.operator,
    this.limit,
  });

  @override
  List<Object> get props => [
        if (phoneNumber != null) phoneNumber!,
        if (startDate != null) startDate!,
        if (endDate != null) endDate!,
        if (operator != null) operator!,
        if (limit != null) limit!,
      ];
}

class FetchFundDebitCreditEvent extends DistributorReportEvent {
  final int? walletType;
  final String? type;
  final String? mobile;
  final String? startDate;
  final String? endDate;
  final int? limit;

  FetchFundDebitCreditEvent({
    this.walletType,
    this.type,
    this.mobile,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object> get props => [
        if (walletType != null) walletType!,
        if (type != null) type!,
        if (mobile != null) mobile!,
        if (startDate != null) startDate!,
        if (endDate != null) endDate!,
        if (limit != null) limit!,
      ];
}

class FetchDisputeSettlementEvent extends DistributorReportEvent {
  final String? status;
  final String? startDate;
  final String? endDate;
  final int? limit;

  FetchDisputeSettlementEvent({
    this.status,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object> get props => [
        if (status != null) status!,
        if (startDate != null) startDate!,
        if (endDate != null) endDate!,
        if (limit != null) limit!,
      ];
}

