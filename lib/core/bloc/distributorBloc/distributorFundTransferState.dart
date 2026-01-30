import 'package:equatable/equatable.dart';
import '../../models/distributorModels/distributorFundTransferModel.dart';

abstract class DistributorFundTransferState extends Equatable {
  @override
  List<Object> get props => [];
}

class DistributorFundTransferInitial extends DistributorFundTransferState {}

class DistributorFundTransferSearchLoading extends DistributorFundTransferState {}

class DistributorFundTransferSearchLoaded extends DistributorFundTransferState {
  final List<FundTransferUser> users;

  DistributorFundTransferSearchLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class DistributorFundTransferAllUsersLoading extends DistributorFundTransferState {}

class DistributorFundTransferAllUsersLoaded extends DistributorFundTransferState {
  final List<FundTransferUser> users;

  DistributorFundTransferAllUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class DistributorFundTransferLoading extends DistributorFundTransferState {}

class DistributorFundTransferSuccess extends DistributorFundTransferState {
  final FundTransferResponse response;

  DistributorFundTransferSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class DistributorFundTransferRequiresSecureKey extends DistributorFundTransferState {
  final String? errorMessage;

  DistributorFundTransferRequiresSecureKey({this.errorMessage});

  @override
  List<Object> get props => [errorMessage ?? ''];
}

class DistributorFundTransferError extends DistributorFundTransferState {
  final String message;

  DistributorFundTransferError(this.message);

  @override
  List<Object> get props => [message];
}

