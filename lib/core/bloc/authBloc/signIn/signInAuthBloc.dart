import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/signIn/signInAuthRepository.dart';
import '../../../repository/signIn/signInAuthRepository.dart' as repo;
import '../../../services/fcm_service.dart';
import 'signInAuthEvent.dart';
import 'signInAuthState.dart';


class signInAuthBloc extends Bloc<signInAuthEvent, signInAuthState> {
  final signInAuthRepository authRepository;
  final FCMService _fcmService = FCMService();

  signInAuthBloc(this.authRepository) : super(signInAuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(signInAuthLoading());
      try {
        // Get FCM token if available
        final fcmToken = _fcmService.fcmToken;
        final user = await authRepository.login(event.username, event.password, fcmToken: fcmToken);
        
        // Register FCM token with backend after successful login
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await _fcmService.registerPendingToken();
        }
        
        emit(signInAuthSuccess(user));
      } catch (e) {
        print('Login error: ${e}');
        // Check if it's an OTP required exception
        if (e is repo.OtpRequiredException) {
          emit(signInAuthOtpRequired(
            userId: e.userId,
            loginType: e.loginType,
            message: e.message,
          ));
        } else if (e is repo.UnauthorizedRoleException) {
          // Handle unauthorized role exception
          emit(signInAuthFailure(loginErrorMessage: e.toString()));
        } else {
          emit(signInAuthFailure(loginErrorMessage: e.toString()));
        }
      }
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(signInAuthLoading());
      try {
        // Get FCM token if available
        final fcmToken = _fcmService.fcmToken;
        final user = await authRepository.verifyOtp(event.username, event.otp, fcmToken: fcmToken);
        
        // Register FCM token with backend after successful login
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await _fcmService.registerPendingToken();
        }
        
        emit(signInAuthSuccess(user));
      } catch (e) {
        print('OTP verification error: ${e}');
        // Check if it's an unauthorized role exception
        if (e is repo.UnauthorizedRoleException) {
          emit(signInAuthFailure(loginErrorMessage: e.toString()));
        } else {
          emit(signInAuthFailure(loginErrorMessage: e.toString()));
        }
      }
    });
  }
}
