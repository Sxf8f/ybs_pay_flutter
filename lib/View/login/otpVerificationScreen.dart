import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/View/widgets/progressiveDotsLoading.dart';
import 'package:ybs_pay/View/widgets/snackBar.dart';
import 'package:ybs_pay/core/bloc/authBloc/signIn/signInAuthBloc.dart';
import 'package:ybs_pay/core/bloc/authBloc/signIn/signInAuthEvent.dart';
import 'package:ybs_pay/core/bloc/authBloc/signIn/signInAuthState.dart';
import 'package:ybs_pay/core/const/color_const.dart';
import 'package:ybs_pay/core/auth/tokenRefreshService.dart';
import 'package:ybs_pay/main.dart';
import 'package:ybs_pay/splashScreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String userId;
  final String loginType;
  final String message;

  const OtpVerificationScreen({
    Key? key,
    required this.userId,
    required this.loginType,
    required this.message,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOtp(BuildContext context) {
    final otp = _getOtp();
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter complete 6-digit OTP';
      });
      showSnack(context, 'Please enter complete 6-digit OTP');
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    context.read<signInAuthBloc>().add(
          VerifyOtpRequested(
            username: widget.userId,
            otp: otp,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorConst.lightBlue,
      body: BlocConsumer<signInAuthBloc, signInAuthState>(
        listener: (context, state) {
          if (state is signInAuthSuccess) {
            // Start token refresh service after successful OTP verification
            TokenRefreshService.start();
            // After successful OTP verification, navigate to splash
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const splashScreen()),
            );
          } else if (state is signInAuthFailure) {
            setState(() {
              _errorMessage = state.loginErrorMessage;
            });
            showSnack(context, state.loginErrorMessage);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/pexels-jplenio-1103970.webp",
                  ),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),

                        // Title
                        Text(
                          'OTP Verification',
                          style: TextStyle(
                            fontSize: scrWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15),

                        // Message
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            widget.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: scrWidth * 0.035,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        // User ID info
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'User ID: ${widget.userId}',
                            style: TextStyle(
                              fontSize: scrWidth * 0.03,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),

                        // Error message
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.white),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: scrWidth * 0.03,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // OTP Input Fields
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(scrWidth * 0.04),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return Container(
                                width: scrWidth * 0.12,
                                height: scrWidth * 0.12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: TextStyle(
                                    fontSize: scrWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onChanged: (value) {
                                    _onOtpChanged(index, value);
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 40),

                        // Verify Button
                        state is signInAuthLoading
                            ? progressiveDotsLoading()
                            : Container(
                                width: double.infinity,
                                height: scrWidth * 0.12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(scrWidth * 0.03),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _verifyOtp(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        scrWidth * 0.03,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      fontSize: scrWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(height: 20),

                        // Resend OTP option
                        TextButton(
                          onPressed: () {
                            showSnack(
                              context,
                              'Please login again to receive a new OTP',
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Didn\'t receive OTP? Login again',
                            style: TextStyle(
                              fontSize: scrWidth * 0.03,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}