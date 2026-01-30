import 'package:equatable/equatable.dart';
import '../../models/distributorModels/distributorReportModel.dart';

abstract class DistributorReportState extends Equatable {
  @override
  List<Object> get props => [];
}

class DistributorReportInitial extends DistributorReportState {}

class DistributorReportLoading extends DistributorReportState {}

class DistributorReportError extends DistributorReportState {
  final String message;

  DistributorReportError(this.message);

  @override
  List<Object> get props => [message];
}

class UserLedgerLoaded extends DistributorReportState {
  final UserLedgerResponse ledger;

  UserLedgerLoaded(this.ledger);

  @override
  List<Object> get props => [ledger];
}

class UserDaybookLoaded extends DistributorReportState {
  final UserDaybookResponse daybook;

  UserDaybookLoaded(this.daybook);

  @override
  List<Object> get props => [daybook];
}

class FundDebitCreditLoaded extends DistributorReportState {
  final FundDebitCreditResponse report;

  FundDebitCreditLoaded(this.report);

  @override
  List<Object> get props => [report];
}

class DisputeSettlementLoaded extends DistributorReportState {
  final DisputeSettlementResponse dispute;

  DisputeSettlementLoaded(this.dispute);

  @override
  List<Object> get props => [dispute];
}

