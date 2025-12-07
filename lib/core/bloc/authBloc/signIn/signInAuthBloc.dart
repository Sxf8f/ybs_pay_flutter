import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/signIn/signInAuthRepository.dart';
import 'signInAuthEvent.dart';
import 'signInAuthState.dart';


class signInAuthBloc extends Bloc<signInAuthEvent, signInAuthState> {
  final signInAuthRepository authRepository;

  signInAuthBloc(this.authRepository) : super(signInAuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(signInAuthLoading());
      try {
        final user = await authRepository.login(event.username, event.password);
        emit(signInAuthSuccess(user));
      } catch (e) {
        print('${e} ygkugkgk' );
        emit(signInAuthFailure(loginErrorMessage: e.toString()));
      }
    });
  }
}
