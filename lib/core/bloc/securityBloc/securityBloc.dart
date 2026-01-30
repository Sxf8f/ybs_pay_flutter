import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/securityRepository/securityRepo.dart';
import 'securityEvent.dart';
import 'securityState.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityRepository securityRepository;

  SecurityBloc({required this.securityRepository}) : super(SecurityInitial()) {
    on<FetchDoubleFactorStatus>((event, emit) async {
      emit(SecurityLoading());
      try {
        final status = await securityRepository.getDoubleFactorStatus();
        emit(DoubleFactorStatusLoaded(status: status));
      } catch (e) {
        emit(SecurityError(message: e.toString()));
      }
    });

    on<ToggleDoubleFactor>((event, emit) async {
      emit(SecurityLoading());
      try {
        final response = await securityRepository.toggleDoubleFactor(event.enabled);
        emit(DoubleFactorToggled(response: response));
        // Refresh status after toggle
        final status = await securityRepository.getDoubleFactorStatus();
        emit(DoubleFactorStatusLoaded(status: status));
      } catch (e) {
        emit(SecurityError(message: e.toString()));
      }
    });

    on<ChangePinPassword>((event, emit) async {
      emit(SecurityLoading());
      try {
        final response = await securityRepository.changePinPassword(
          currentPin: event.currentPin,
          newPin: event.newPin,
          confirmPin: event.confirmPin,
        );
        emit(PinPasswordChanged(response: response));
      } catch (e) {
        emit(SecurityError(message: e.toString()));
      }
    });

    on<RegenerateSecureKey>((event, emit) async {
      emit(SecurityLoading());
      try {
        final response = await securityRepository.regenerateSecureKey();
        emit(SecureKeyRegenerated(response: response));
      } catch (e) {
        emit(SecurityError(message: e.toString()));
      }
    });
  }
}

