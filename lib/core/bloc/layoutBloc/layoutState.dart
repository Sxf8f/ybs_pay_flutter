// lib/blocs/layout/layout_state.dart
import 'package:equatable/equatable.dart';
import '../../models/authModels/userModel.dart';

abstract class LayoutState extends Equatable {
  const LayoutState();

  @override
  List<Object?> get props => [];
}

class LayoutInitial extends LayoutState {}

class LayoutLoading extends LayoutState {}

class LayoutLoaded extends LayoutState {
  final List<LayoutModel> layouts;

  const LayoutLoaded(this.layouts);

  @override
  List<Object?> get props => [layouts];
}

class LayoutError extends LayoutState {
  final String message;

  const LayoutError(this.message);

  @override
  List<Object?> get props => [message];
}
