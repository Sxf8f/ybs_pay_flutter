import 'package:equatable/equatable.dart';

abstract class signUpState extends Equatable{
  @override
  List<Object?> get props =>[];
}
class signUpInitial extends signUpState{}
class signUpLoading extends signUpState{}
class signUpSuccess extends signUpState{
  final String message;
  signUpSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}
class signUpFailure extends signUpState{
  final String error;
  signUpFailure({required this.error});
  @override
  List<Object?> get props => [error];
}




