import 'package:equatable/equatable.dart';
import '../../models/distributorModels/distributorUserModel.dart';

abstract class DistributorUserState extends Equatable {
  @override
  List<Object> get props => [];
}

class DistributorUserInitial extends DistributorUserState {}

class DistributorUserLoading extends DistributorUserState {}

class DistributorUserCreating extends DistributorUserState {}

class DistributorUserListLoaded extends DistributorUserState {
  final UserListResponse userList;

  DistributorUserListLoaded(this.userList);

  @override
  List<Object> get props => [userList];
}

class DistributorUserCreated extends DistributorUserState {
  final CreateUserResponse response;

  DistributorUserCreated(this.response);

  @override
  List<Object> get props => [response];
}

class DistributorUserError extends DistributorUserState {
  final String message;

  DistributorUserError(this.message);

  @override
  List<Object> get props => [message];
}

