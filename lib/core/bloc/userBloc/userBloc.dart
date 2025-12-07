import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/userRepository/userRepo.dart';
import 'userEvent.dart';
import 'userState.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<FetchUserDetailsEvent>(_onFetchUserDetails);
  }

  Future<void> _onFetchUserDetails(
    FetchUserDetailsEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await repository.fetchUserDetails();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
