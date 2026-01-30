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
import 'package:ybs_pay/View/login/otpVerificationScreen.dart';
import 'package:ybs_pay/View/widgets/progressiveDotsLoading.dart';
import 'package:ybs_pay/core/sharedPreference/credential/removeCredential.dart';
import 'package:ybs_pay/core/sharedPreference/credential/storeCredential.dart';
import 'package:ybs_pay/core/auth/tokenRefreshService.dart';
import '../../core/bloc/authBloc/signIn/signInAuthBloc.dart';
import '../../core/bloc/authBloc/signIn/signInAuthEvent.dart';
import '../../core/bloc/authBloc/signIn/signInAuthState.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appState.dart';
import '../../core/bloc/appBloc/appEvent.dart';
import '../../core/bloc/userBloc/userBloc.dart';
import '../../core/bloc/userBloc/userEvent.dart';
import '../../core/bloc/layoutBloc/layoutBloc.dart';
import '../../core/bloc/layoutBloc/layoutEvent.dart';
import '../../core/bloc/notificationBloc/notificationBloc.dart';
import '../../core/bloc/notificationBloc/notificationEvent.dart';
import '../../core/const/color_const.dart';
import '../../core/const/assets_const.dart';
import '../../core/repository/signIn/signInAuthRepository.dart';
import '../../main.dart';
import 'package:ybs_pay/splashScreen.dart';
import '../widgets/snackBar.dart';

class loginScreen extends ConsumerStatefulWidget {
  final String? logoutMessage;

  loginScreen({Key? key, this.logoutMessage}) : super(key: key);

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
  String? _logoutInfoMessage;

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

    // If we were redirected here due to forced logout (e.g. password reset),
    // capture a one-time info message to show in the UI.
    if (widget.logoutMessage != null &&
        widget.logoutMessage!.trim().isNotEmpty) {
      _logoutInfoMessage = widget.logoutMessage!.trim();
    }
    // Fetch settings to get logo from API (same as home_app_bar.dart)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔍 LOGIN PAGE: Fetching settings for logo...');
        context.read<AppBloc>().add(FetchSettingsEvent());
      }
    });
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
              // Start token refresh service after successful login
              TokenRefreshService.start();
              // After successful login (normal or via OTP), ALWAYS go through splashScreen
              // so that all central checks in splash (role, token validation, etc.)
              // run before navigating to the correct home screen.
              if (rememberCheckBox) {
                storeCredential(_userController, _passController);
              } else {
                removeCredential();
              }

              // Dispatch events to fetch necessary data (similar to splash screen)
              try {
                context.read<UserBloc>().add(FetchUserDetailsEvent());
              } catch (e) {
                print('⚠️ Error dispatching FetchUserDetailsEvent: $e');
              }
              try {
                context.read<AppBloc>().add(FetchNewsEvent());
              } catch (e) {
                print('⚠️ Error dispatching FetchNewsEvent: $e');
              }
              try {
                context.read<LayoutBloc>().add(FetchLayoutsEvent());
              } catch (e) {
                print('⚠️ Error dispatching FetchLayoutsEvent: $e');
              }
              try {
                context.read<NotificationBloc>().add(
                  const FetchNotificationStatsEvent(),
                );
              } catch (e) {
                print('⚠️ Error dispatching FetchNotificationStatsEvent: $e');
              }

              // Navigate to splashScreen; it will then decide whether to go to
              // home or back to login based on token/role conditions.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const splashScreen()),
              );
            } else if (state is signInAuthOtpRequired) {
              // Navigate to OTP verification screen with bloc
              final bloc = context.read<signInAuthBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: OtpVerificationScreen(
                      userId: state.userId,
                      loginType: state.loginType,
                      message: state.message,
                    ),
                  ),
                ),
              );
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
                                // Logo from API (same logic as home_app_bar.dart)
                                BlocBuilder<AppBloc, AppState>(
                                  buildWhen: (previous, current) {
                                    print(
                                      '🔍 LOGIN PAGE LOGO: buildWhen called',
                                    );
                                    print(
                                      '  Previous state: ${previous.runtimeType}',
                                    );
                                    print(
                                      '  Current state: ${current.runtimeType}',
                                    );
                                    print(
                                      '  Should rebuild: ${current is AppLoaded}',
                                    );

                                    // Also rebuild on AppError to show error message
                                    if (current is AppError) {
                                      print(
                                        '  ⚠️ Current state is AppError: ${current.message}',
                                      );
                                    }

                                    return current is AppLoaded ||
                                        current is AppError;
                                  },
                                  builder: (context, state) {
                                    print('🔍 LOGIN PAGE LOGO DEBUG:');
                                    print('  State type: ${state.runtimeType}');

                                    // Handle AppError state
                                    if (state is AppError) {
                                      print('  ❌ AppError state detected!');
                                      print(
                                        '  Error message: ${state.message}',
                                      );
                                      print(
                                        '  This means the API call failed. Check repository logs above.',
                                      );
                                      return SizedBox.shrink();
                                    }

                                    String? logoPath;
                                    if (state is AppLoaded &&
                                        state.settings?.logo != null) {
                                      logoPath =
                                          "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                                      print('  ✅ State is AppLoaded');
                                      print('  ✅ Settings: ${state.settings}');
                                      print(
                                        '  ✅ Logo: ${state.settings!.logo}',
                                      );
                                      print(
                                        '  ✅ Logo image from API: ${state.settings!.logo!.image}',
                                      );
                                      print('  ✅ Full logo URL: $logoPath');
                                    } else {
                                      print(
                                        '  ⚠️ State is not AppLoaded or logo is null',
                                      );
                                      print(
                                        '  State type: ${state.runtimeType}',
                                      );
                                      if (state is AppLoaded) {
                                        print('  Settings: ${state.settings}');
                                        print(
                                          '  Settings?.logo: ${state.settings?.logo}',
                                        );
                                        if (state.settings == null) {
                                          print(
                                            '  ⚠️ Settings is null - API might not have returned settings',
                                          );
                                        } else if (state.settings!.logo ==
                                            null) {
                                          print(
                                            '  ⚠️ Logo is null - API response might not include logo',
                                          );
                                        }
                                      }
                                    }

                                    // Only show logo if we have a valid URL from API
                                    if (logoPath != null &&
                                        logoPath.startsWith('http')) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                          bottom: 2,
                                          top: 15,
                                        ),
                                        height:
                                            MediaQuery.of(context).size.width *
                                            0.15,
                                        child: Image.network(
                                          logoPath,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              print(
                                                '  ✅ Logo loaded successfully',
                                              );
                                              return child;
                                            }
                                            print(
                                              '  ⏳ Logo loading... ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}',
                                            );
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            print(
                                              '  ❌ Logo failed to load: $error',
                                            );
                                            print(
                                              '  ❌ Stack trace: $stackTrace',
                                            );
                                            return SizedBox.shrink(); // Don't show anything on error
                                          },
                                        ),
                                      );
                                    }

                                    print(
                                      '  ℹ️ No logo to display - returning empty widget',
                                    );
                                    return SizedBox.shrink(); // Don't show anything if no logo from API
                                  },
                                ),
                                signInText(),
                                // Info message shown when user was logged out (e.g. password reset)
                                if (_logoutInfoMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        _logoutInfoMessage!,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
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
