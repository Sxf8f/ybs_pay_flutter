import 'package:equatable/equatable.dart';
import '../../models/distributorModels/distributorCommissionModel.dart';

abstract class DistributorCommissionState extends Equatable {
  @override
  List<Object> get props => [];
}

class DistributorCommissionInitial extends DistributorCommissionState {}

class DistributorCommissionLoading extends DistributorCommissionState {}

class DistributorCommissionLoaded extends DistributorCommissionState {
  final CommissionSlabResponse commission;

  DistributorCommissionLoaded(this.commission);

  @override
  List<Object> get props => [commission];
}

class DistributorCommissionError extends DistributorCommissionState {
  final String message;

  DistributorCommissionError(this.message);

  @override
  List<Object> get props => [message];
}

