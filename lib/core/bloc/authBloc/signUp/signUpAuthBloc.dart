
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/core/bloc/authBloc/signUp/signUpAuthEvent.dart';
import 'package:ybs_pay/core/bloc/authBloc/signUp/signUpAuthState.dart';

import '../../../repository/signUp/signUpRepository.dart';

class signUpBloc extends Bloc<signupEvent, signUpState>{
  final signUpRepository signupRepository;
  signUpBloc({required this.signupRepository}) : super(signUpInitial()){
    on<signupSubmitted>((event, emit) async {
      emit(signUpLoading());
      try{
        final msg = await signupRepository.signUp(
            username: event.username,
            email: event.email,
            password: event.password,
            phoneNumber: event.phoneNumber,
            pinCode: event.pinCode,
            address: event.address
        );
        emit(signUpSuccess(message: msg));
      }catch(e){
        emit(signUpFailure(error: e.toString()));

      }
    });
  }
}

