// auth_state.dart
import 'package:equatable/equatable.dart';

import '../../../models/authModels/userModel.dart';

// abstract class signInAuthState {}
//
// class AuthInitial extends signInAuthState {}
//
// class signInAuthLoading extends signInAuthState {}
//
// class signInAuthSuccess extends signInAuthState {
//   final UserModel user;
//   signInAuthSuccess(this.user);
// }
//
// class signInAuthFailure extends signInAuthState {
//   final String error;
//   signInAuthFailure(this.error);
// }







abstract class signInAuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class signInAuthInitial extends signInAuthState {}

class signInAuthLoading extends signInAuthState {}

class signInAuthSuccess extends signInAuthState {
  final UserModel user;
  signInAuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class signInAuthFailure extends signInAuthState {
  final String loginErrorMessage;

  signInAuthFailure({required this.loginErrorMessage});

  @override
  List<Object> get props => [loginErrorMessage];
}
