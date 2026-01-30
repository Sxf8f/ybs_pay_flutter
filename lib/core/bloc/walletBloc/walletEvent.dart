import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchWalletBalance extends WalletEvent {}

class FetchPaymentMethods extends WalletEvent {}

class AddMoneyRequested extends WalletEvent {
  final String amount;
  final String operator;
  final String? secureKey;

  AddMoneyRequested({
    required this.amount,
    required this.operator,
    this.secureKey,
  });

  @override
  List<Object> get props => [amount, operator, secureKey ?? ''];
}

class CheckPaymentStatus extends WalletEvent {
  final String transactionId;

  CheckPaymentStatus({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}

class FetchWalletHistory extends WalletEvent {
  final String? status;
  final String? startDate;
  final String? endDate;
  final int? limit;
  final String? search;

  FetchWalletHistory({
    this.status,
    this.startDate,
    this.endDate,
    this.limit,
    this.search,
  });

  @override
  List<Object> get props => [
        status ?? '',
        startDate ?? '',
        endDate ?? '',
        limit ?? 0,
        search ?? '',
      ];
}

class GenerateQRRequested extends WalletEvent {}

class ValidateQRRequested extends WalletEvent {
  final String qrData;

  ValidateQRRequested({required this.qrData});

  @override
  List<Object> get props => [qrData];
}

class TransferMoneyRequested extends WalletEvent {
  final int recipientUserId;
  final String amount;
  final String? remarks;
  final String? qrData;

  TransferMoneyRequested({
    required this.recipientUserId,
    required this.amount,
    this.remarks,
    this.qrData,
  });

  @override
  List<Object> get props => [
        recipientUserId,
        amount,
        remarks ?? '',
        qrData ?? '',
      ];
}

class FetchTransferHistory extends WalletEvent {
  final String? type;
  final String? startDate;
  final String? endDate;
  final int? limit;
  final int? offset;

  FetchTransferHistory({
    this.type,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
  });

  @override
  List<Object> get props => [
        type ?? '',
        startDate ?? '',
        endDate ?? '',
        limit ?? 0,
        offset ?? 0,
      ];
}

