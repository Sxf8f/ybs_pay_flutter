import 'package:equatable/equatable.dart';

abstract class DistributorScanPayEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ValidateQREvent extends DistributorScanPayEvent {
  final String qrData;

  ValidateQREvent({required this.qrData});

  @override
  List<Object> get props => [qrData];
}

class TransferViaQREvent extends DistributorScanPayEvent {
  final int recipientUserId;
  final String amount;
  final String qrData;
  final String? remarks;
  final String? secureKey;

  TransferViaQREvent({
    required this.recipientUserId,
    required this.amount,
    required this.qrData,
    this.remarks,
    this.secureKey,
  });

  @override
  List<Object> get props => [
        recipientUserId,
        amount,
        qrData,
        if (remarks != null) remarks!,
        if (secureKey != null) secureKey!,
      ];
}

