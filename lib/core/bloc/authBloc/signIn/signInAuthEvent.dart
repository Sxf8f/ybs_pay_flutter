import 'package:equatable/equatable.dart';




abstract class signInAuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginRequested extends signInAuthEvent {
  final String username;
  final String password;

  LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}
