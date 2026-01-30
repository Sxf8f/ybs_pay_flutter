import 'package:equatable/equatable.dart';
import '../../models/distributorModels/distributorScanPayModel.dart';

abstract class DistributorScanPayState extends Equatable {
  @override
  List<Object> get props => [];
}

class DistributorScanPayInitial extends DistributorScanPayState {}

class DistributorScanPayLoading extends DistributorScanPayState {}

class DistributorScanPayQRValidated extends DistributorScanPayState {
  final ValidateQRResponse validation;
  final String qrData;

  DistributorScanPayQRValidated({
    required this.validation,
    required this.qrData,
  });

  @override
  List<Object> get props => [validation, qrData];
}

class DistributorScanPayTransferLoading extends DistributorScanPayState {}

class DistributorScanPayTransferSuccess extends DistributorScanPayState {
  final QRTransferResponse response;

  DistributorScanPayTransferSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class DistributorScanPayRequiresSecureKey extends DistributorScanPayState {}

class DistributorScanPayError extends DistributorScanPayState {
  final String message;

  DistributorScanPayError(this.message);

  @override
  List<Object> get props => [message];
}

