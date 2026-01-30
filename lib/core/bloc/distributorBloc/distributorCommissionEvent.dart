import 'package:equatable/equatable.dart';

abstract class DistributorCommissionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchCommissionSlabEvent extends DistributorCommissionEvent {}

