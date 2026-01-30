import 'package:equatable/equatable.dart';
import '../../models/reportModels/reportModel.dart';

abstract class ReportsState extends Equatable {
  @override
  List<Object> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class RechargeReportLoaded extends ReportsState {
  final RechargeReportResponse response;

  RechargeReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class LedgerReportLoaded extends ReportsState {
  final LedgerReportResponse response;

  LedgerReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class FundOrderReportLoaded extends ReportsState {
  final FundOrderReportResponse response;

  FundOrderReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class ComplaintReportLoaded extends ReportsState {
  final ComplaintReportResponse response;

  ComplaintReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class FundDebitCreditReportLoaded extends ReportsState {
  final FundDebitCreditReportResponse response;

  FundDebitCreditReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class UserDaybookReportLoaded extends ReportsState {
  final UserDaybookReportResponse response;

  UserDaybookReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class CommissionSlabReportLoaded extends ReportsState {
  final CommissionSlabReportResponse response;

  CommissionSlabReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class W2RReportLoaded extends ReportsState {
  final W2RReportResponse response;

  W2RReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class DaybookDMTReportLoaded extends ReportsState {
  final DaybookDMTReportResponse response;

  DaybookDMTReportLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class ReportsError extends ReportsState {
  final String message;

  ReportsError({required this.message});

  @override
  List<Object> get props => [message];
}

