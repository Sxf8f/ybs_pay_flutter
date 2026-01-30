import 'package:equatable/equatable.dart';

abstract class SecurityEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchDoubleFactorStatus extends SecurityEvent {}

class ToggleDoubleFactor extends SecurityEvent {
  final bool enabled;

  ToggleDoubleFactor({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

class ChangePinPassword extends SecurityEvent {
  final String? currentPin;
  final String newPin;
  final String confirmPin;

  ChangePinPassword({
    this.currentPin,
    required this.newPin,
    required this.confirmPin,
  });

  @override
  List<Object> get props => [
        currentPin ?? '',
        newPin,
        confirmPin,
      ];
}

class RegenerateSecureKey extends SecurityEvent {}

