import 'package:equatable/equatable.dart';
import '../../models/supportModels/supportModel.dart';

abstract class SupportState extends Equatable {
  const SupportState();

  @override
  List<Object> get props => [];
}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportLoaded extends SupportState {
  final SupportData data;

  const SupportLoaded({required this.data});

  @override
  List<Object> get props => [data];
}

class SupportError extends SupportState {
  final String message;

  const SupportError(this.message);

  @override
  List<Object> get props => [message];
}

