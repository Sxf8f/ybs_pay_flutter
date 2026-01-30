import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/distributorRepository/distributorRepo.dart';
import 'distributorUserEvent.dart';
import 'distributorUserState.dart';

class DistributorUserBloc extends Bloc<DistributorUserEvent, DistributorUserState> {
  final DistributorRepository repository;

  DistributorUserBloc(this.repository) : super(DistributorUserInitial()) {
    on<FetchUserListEvent>(_onFetchUserList);
    on<CreateUserEvent>(_onCreateUser);
  }

  Future<void> _onFetchUserList(
    FetchUserListEvent event,
    Emitter<DistributorUserState> emit,
  ) async {
    emit(DistributorUserLoading());
    try {
      final userList = await repository.getUserList(
        page: event.page,
        limit: event.limit,
        search: event.search,
        role: event.role,
        criteria: event.criteria,
        searchValue: event.searchValue,
        phoneNumber: event.phoneNumber,
      );
      emit(DistributorUserListLoaded(userList));
    } catch (e) {
      emit(DistributorUserError(e.toString()));
    }
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<DistributorUserState> emit,
  ) async {
    emit(DistributorUserCreating());
    try {
      final response = await repository.createUser(
        username: event.username,
        email: event.email,
        phoneNumber: event.phoneNumber,
        pincode: event.pincode,
        address: event.address,
        outlet: event.outlet,
        roleId: event.roleId,
      );
      emit(DistributorUserCreated(response));
    } catch (e) {
      emit(DistributorUserError(e.toString()));
    }
  }
}

