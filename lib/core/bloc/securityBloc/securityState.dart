import 'package:equatable/equatable.dart';
import '../../models/securityModels/securityModel.dart';

abstract class SecurityState extends Equatable {
  @override
  List<Object> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class DoubleFactorStatusLoaded extends SecurityState {
  final DoubleFactorStatusResponse status;

  DoubleFactorStatusLoaded({required this.status});

  @override
  List<Object> get props => [status];
}

class DoubleFactorToggled extends SecurityState {
  final ToggleDoubleFactorResponse response;

  DoubleFactorToggled({required this.response});

  @override
  List<Object> get props => [response];
}

class PinPasswordChanged extends SecurityState {
  final ChangePinPasswordResponse response;

  PinPasswordChanged({required this.response});

  @override
  List<Object> get props => [response];
}

class SecureKeyRegenerated extends SecurityState {
  final RegenerateSecureKeyResponse response;

  SecureKeyRegenerated({required this.response});

  @override
  List<Object> get props => [response];
}

class SecurityError extends SecurityState {
  final String message;

  SecurityError({required this.message});

  @override
  List<Object> get props => [message];
}

