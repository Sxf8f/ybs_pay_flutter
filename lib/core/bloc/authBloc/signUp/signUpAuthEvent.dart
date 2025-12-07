import 'package:equatable/equatable.dart';

abstract class signupEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class signupSubmitted extends signupEvent {
  final String username;
  final String email;
  final String password;
  final String phoneNumber;
  final String pinCode;
  final String address;
  signupSubmitted({
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.pinCode,
    required this.address,
  });
  @override
  List<Object> get props => [username, email, password, phoneNumber, pinCode, address];
}
