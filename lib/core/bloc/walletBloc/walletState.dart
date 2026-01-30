import 'package:equatable/equatable.dart';
import '../../models/walletModels/walletModel.dart';

abstract class WalletState extends Equatable {
  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletBalanceLoaded extends WalletState {
  final WalletBalanceResponse balance;

  WalletBalanceLoaded({required this.balance});

  @override
  List<Object> get props => [balance];
}

class PaymentMethodsLoaded extends WalletState {
  final PaymentMethodsResponse paymentMethods;

  PaymentMethodsLoaded({required this.paymentMethods});

  @override
  List<Object> get props => [paymentMethods];
}

class AddMoneySuccess extends WalletState {
  final AddMoneyResponse response;

  AddMoneySuccess({required this.response});

  @override
  List<Object> get props => [response];
}

class PaymentStatusChecked extends WalletState {
  final PaymentStatusResponse status;

  PaymentStatusChecked({required this.status});

  @override
  List<Object> get props => [status];
}

class WalletHistoryLoaded extends WalletState {
  final WalletHistoryResponse history;

  WalletHistoryLoaded({required this.history});

  @override
  List<Object> get props => [history];
}

class WalletError extends WalletState {
  final String message;

  WalletError({required this.message});

  @override
  List<Object> get props => [message];
}

class QRCodeGenerated extends WalletState {
  final QRCodeResponse qrCode;

  QRCodeGenerated({required this.qrCode});

  @override
  List<Object> get props => [qrCode];
}

class QRValidated extends WalletState {
  final ValidateQRResponse validation;

  QRValidated({required this.validation});

  @override
  List<Object> get props => [validation];
}

class TransferMoneySuccess extends WalletState {
  final TransferMoneyResponse response;

  TransferMoneySuccess({required this.response});

  @override
  List<Object> get props => [response];
}

class TransferHistoryLoaded extends WalletState {
  final TransferHistoryResponse history;

  TransferHistoryLoaded({required this.history});

  @override
  List<Object> get props => [history];
}

