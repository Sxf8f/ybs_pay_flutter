import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ybs_pay/View/signUp/widgets/alreadyHaveAccount.dart';
import 'package:ybs_pay/View/signUp/widgets/errorText.dart';
import 'package:ybs_pay/View/signUp/widgets/signUpButton.dart';
import 'package:ybs_pay/View/signUp/widgets/signinText.dart';
import 'package:ybs_pay/View/signUp/widgets/signupAddressField.dart';
import 'package:ybs_pay/View/signUp/widgets/signupMailField.dart';
import 'package:ybs_pay/View/signUp/widgets/signupPhoneField.dart';
import 'package:ybs_pay/View/signUp/widgets/signupPincodeField.dart';
import 'package:ybs_pay/View/signUp/widgets/userField.dart';
import 'package:ybs_pay/core/bloc/authBloc/signUp/signUpAuthBloc.dart';
import 'package:ybs_pay/core/bloc/authBloc/signUp/signUpAuthEvent.dart';
import 'package:ybs_pay/core/bloc/authBloc/signUp/signUpAuthState.dart';
import 'package:ybs_pay/core/repository/signUp/signUpRepository.dart';

import '../../core/const/color_const.dart';
import '../../main.dart';
import '../login/loginScreen.dart';
import '../login/widgets/privacyPolicy.dart';
import '../widgets/progressiveDotsLoading.dart';
import '../widgets/snackBar.dart';

class signUpScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<signUpScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<signUpScreen> {
  bool privacyPolicy = false;
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _addressController = TextEditingController();

  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => signUpBloc(signupRepository: signUpRepository()),
      child: Scaffold(
        backgroundColor: colorConst.lightBlue,
        body: BlocConsumer<signUpBloc, signUpState>(
          listener: (context, state) {
            if (state is signUpSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => loginScreen()),
              );
            } else if (state is signUpFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * 1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/pexels-jplenio-1103970.webp",
                      ),
                      fit: BoxFit.cover,
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                scrWidth * 0.04,
                              ),
                              color: Colors.white30,
                            ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                signUpText(),

                                signUpErrorText(errorMessage: _errorMessage),

                                Container(
                                  child: Column(
                                    children: [
                                      signupUserField(
                                        userIDController: _userController,
                                      ),
                                      signupMailField(
                                        userMailController: _emailController,
                                      ),

                                      // signupPasswordField(passwordController: _passController),
                                      signupPhoneField(
                                        phoneController: _phoneController,
                                      ),
                                      signupPinCodeField(
                                        pinCodeController: _pinCodeController,
                                      ),
                                      signupAddressField(
                                        addressController: _addressController,
                                      ),

                                      privacyPolicyCheckBox(
                                        value: privacyPolicy,
                                        onChanged: (value) {
                                          setState(() {
                                            privacyPolicy = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                state is signUpLoading
                                    ? progressiveDotsLoading()
                                    : signupButton(
                                        onChanged: () async {
                                          print(
                                            'ererer ${_userController.text}',
                                          );

                                          // Validate phone number format (exactly 10 digits)
                                          final phoneNumber = _phoneController
                                              .text
                                              .trim()
                                              .replaceAll(
                                                RegExp(r'[^0-9]'),
                                                '',
                                              );
                                          final isValidPhone =
                                              phoneNumber.length == 10 &&
                                              RegExp(
                                                r'^\d{10}$',
                                              ).hasMatch(phoneNumber);

                                          if (_userController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              _emailController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              _phoneController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              isValidPhone &&
                                              _pinCodeController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              _addressController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              privacyPolicy) {
                                            final user = _userController.text
                                                .trim();
                                            final email = _emailController.text
                                                .trim();
                                            // Password is auto-generated by server, not required from user
                                            final password =
                                                ''; // Not used, but required by event
                                            final phone =
                                                phoneNumber; // Use cleaned phone number
                                            final pinCode = _pinCodeController
                                                .text
                                                .trim();
                                            final address = _addressController
                                                .text
                                                .trim();
                                            context.read<signUpBloc>().add(
                                              signupSubmitted(
                                                username: user,
                                                password: password,
                                                email: email,
                                                phoneNumber: phone,
                                                pinCode: pinCode,
                                                address: address,
                                              ),
                                            );
                                          } else {
                                            if (_userController.text
                                                .trim()
                                                .isEmpty) {
                                              showSnack(
                                                context,
                                                'Please enter Username !',
                                              );
                                            } else if (_emailController.text
                                                .trim()
                                                .isEmpty) {
                                              showSnack(
                                                context,
                                                'Please enter email address !',
                                              );
                                            } else if (_phoneController.text
                                                .trim()
                                                .isEmpty) {
                                              showSnack(
                                                context,
                                                'Please enter phone number !',
                                              );
                                            } else if (!isValidPhone) {
                                              showSnack(
                                                context,
                                                'Phone number must be exactly 10 digits !',
                                              );
                                            } else if (_pinCodeController.text
                                                .trim()
                                                .isEmpty) {
                                              showSnack(
                                                context,
                                                'Please enter pin code !',
                                              );
                                            } else if (_addressController.text
                                                .trim()
                                                .isEmpty) {
                                              showSnack(
                                                context,
                                                'Please enter address !',
                                              );
                                            } else if (!privacyPolicy) {
                                              showSnack(
                                                context,
                                                'Agree to the Terms & Conditions to register',
                                              );
                                            }
                                          }
                                        },
                                      ),

                                alreadyHaveAccount(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // body: ,
      ),
    );
  }
}
