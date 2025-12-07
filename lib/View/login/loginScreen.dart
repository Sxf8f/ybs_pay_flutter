import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybs_pay/View/login/widgets/createAccount.dart';
import 'package:ybs_pay/View/login/widgets/errorText.dart';
import 'package:ybs_pay/View/login/widgets/loginButton.dart';
import 'package:ybs_pay/View/login/widgets/passwordField.dart';
import 'package:ybs_pay/View/login/widgets/privacyPolicy.dart';
import 'package:ybs_pay/View/login/widgets/rememberMe.dart';
import 'package:ybs_pay/View/login/widgets/signinText.dart';
import 'package:ybs_pay/View/login/widgets/userField.dart';
import 'package:ybs_pay/View/widgets/progressiveDotsLoading.dart';
import 'package:ybs_pay/core/sharedPreference/credential/removeCredential.dart';
import 'package:ybs_pay/core/sharedPreference/credential/storeCredential.dart';
import 'package:ybs_pay/splashScreen.dart';
import '../../core/bloc/authBloc/signIn/signInAuthBloc.dart';
import '../../core/bloc/authBloc/signIn/signInAuthEvent.dart';
import '../../core/bloc/authBloc/signIn/signInAuthState.dart';
import '../../core/const/color_const.dart';
import '../../core/repository/signIn/signInAuthRepository.dart';
import '../../main.dart';
import '../widgets/snackBar.dart';

class loginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<loginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<loginScreen> {
  bool rememberCheckBox = false;
  bool privacyPolicy = false;
  bool hide = true;

  final _userController = TextEditingController();
  final _passController = TextEditingController();

  String? _errorMessage;

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('login_remember_me') ?? false;
    if (remember) {
      setState(() {
        rememberCheckBox = true;
        _userController.text = prefs.getString('login_email') ?? '';
        _passController.text = prefs.getString('login_password') ?? '';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => signInAuthBloc(signInAuthRepository()),
      child: Scaffold(
        backgroundColor: colorConst.lightBlue,
        body: BlocConsumer<signInAuthBloc, signInAuthState>(
          listener: (context, state) {
            if (state is signInAuthSuccess) {
              // After successful login, re-bootstrap via splash to validate token and refetch all data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const splashScreen()),
              );
              if (rememberCheckBox) {
                storeCredential(_userController, _passController);
              } else {
                removeCredential();
              }
            } else if (state is signInAuthFailure) {
              _errorMessage = state.loginErrorMessage;
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
                    padding: const EdgeInsets.only(top: 110),
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
                                signInText(),
                                errorText(errorMessage: _errorMessage),

                                Container(
                                  child: Column(
                                    children: [
                                      userField(
                                        userIDController: _userController,
                                      ),

                                      passwordField(
                                        passwordController: _passController,
                                      ),

                                      rememberMe(
                                        value: rememberCheckBox,
                                        onChanged: (value) {
                                          setState(() {
                                            rememberCheckBox = value;
                                          });
                                        },
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
                                state is signInAuthLoading
                                    ? progressiveDotsLoading()
                                    : loginButton(
                                        onChanged: () async {
                                          print(
                                            'ererer ${_userController.text}',
                                          );
                                          if (_userController.text.isNotEmpty &&
                                              _passController.text.isNotEmpty &&
                                              privacyPolicy) {
                                            final user = _userController.text;
                                            final password =
                                                _passController.text;
                                            context.read<signInAuthBloc>().add(
                                              LoginRequested(
                                                username: user,
                                                password: password,
                                              ),
                                            );
                                          } else {
                                            if (_userController.text == '') {
                                              showSnack(
                                                context,
                                                'Please enter login id !',
                                              );
                                            } else if (_passController.text ==
                                                '') {
                                              showSnack(
                                                context,
                                                'Please enter password !',
                                              );
                                            } else if (!privacyPolicy) {
                                              showSnack(
                                                context,
                                                'Agree to the Terms & Conditions to login',
                                              );
                                            }
                                          }
                                        },
                                      ),

                                createAccount(),
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
