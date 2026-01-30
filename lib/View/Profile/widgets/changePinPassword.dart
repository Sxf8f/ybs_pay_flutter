import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/securityBloc/securityBloc.dart';
import '../../../core/bloc/securityBloc/securityEvent.dart';
import '../../../core/bloc/securityBloc/securityState.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';

class changePinPassword extends StatefulWidget {
  const changePinPassword({super.key});

  @override
  State<changePinPassword> createState() => _changePinPasswordState();
}

class _changePinPasswordState extends State<changePinPassword> {
  TextEditingController currentPinController = TextEditingController();
  TextEditingController newPinController = TextEditingController();
  TextEditingController confirmPinController = TextEditingController();
  bool _hasSecureKey = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch status to check if user has secure key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityBloc>().add(FetchDoubleFactorStatus());
    });
  }

  @override
  void dispose() {
    currentPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  bool _validatePin(String pin) {
    // Pin must be 4-6 digits, numeric only
    if (pin.isEmpty) return false;
    if (pin.length < 4 || pin.length > 6) return false;
    return RegExp(r'^\d+$').hasMatch(pin);
  }

  void _changePinPassword() {
    // Clear any previous error
    setState(() {
      _errorMessage = null;
    });

    final currentPin = currentPinController.text.trim();
    final newPin = newPinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    // Validation
    if (_hasSecureKey && currentPin.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your current pin password';
      });
      return;
    }

    if (newPin.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a new pin password';
      });
      return;
    }

    if (!_validatePin(newPin)) {
      setState(() {
        _errorMessage = 'Pin password must be 4-6 digits (numeric only)';
      });
      return;
    }

    if (confirmPin.isEmpty) {
      setState(() {
        _errorMessage = 'Please confirm your new pin password';
      });
      return;
    }

    if (newPin != confirmPin) {
      setState(() {
        _errorMessage = 'New pin and confirm pin do not match';
      });
      return;
    }

    if (_hasSecureKey && currentPin == newPin) {
      setState(() {
        _errorMessage = 'New pin cannot be the same as current pin';
      });
      return;
    }

    // Call API
    context.read<SecurityBloc>().add(
          ChangePinPassword(
            currentPin: _hasSecureKey ? currentPin : null,
            newPin: newPin,
            confirmPin: confirmPin,
          ),
        );
  }

  void changePasswordBox(bool isPassword) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<SecurityBloc>(),
          child: BlocListener<SecurityBloc, SecurityState>(
            listener: (context, state) {
              if (state is PinPasswordChanged) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // Clear fields
                currentPinController.clear();
                newPinController.clear();
                confirmPinController.clear();
                // Clear error message
                setState(() {
                  _errorMessage = null;
                });
                // Refresh double factor status
                context.read<SecurityBloc>().add(FetchDoubleFactorStatus());
              } else if (state is SecurityError) {
                // Show error inside dialog instead of snackbar
                setState(() {
                  _errorMessage = state.message;
                });
              }
            },
            child: BlocBuilder<SecurityBloc, SecurityState>(
              builder: (context, state) {
                // Update hasSecureKey based on state
                bool hasSecureKey = _hasSecureKey;
                if (state is DoubleFactorStatusLoaded) {
                  hasSecureKey = state.status.hasSecureKey;
                  _hasSecureKey = hasSecureKey;
                }

                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Change Pin Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: scrWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: colorConst.primaryColor3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: scrWidth * 0.8,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasSecureKey) ...[
                            SizedBox(
                              width: scrWidth * 0.7,
                              child: TextFormField(
                                controller: currentPinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 6,
                                style: TextStyle(
                                  fontSize: scrWidth * 0.033,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                                textInputAction: TextInputAction.next,
                                cursorColor: Colors.grey,
                                onChanged: (_) {
                                  // Clear error when user starts typing
                                  if (_errorMessage != null) {
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: "Current Pin Password",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: scrWidth * 0.028,
                                  ),
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(scrWidth * 0.015),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(scrWidth * 0.015),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                          SizedBox(
                            width: scrWidth * 0.7,
                            child: TextFormField(
                              controller: newPinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 6,
                              style: TextStyle(
                                fontSize: scrWidth * 0.033,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.grey,
                              onChanged: (_) {
                                // Clear error when user starts typing
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                hintText: "New Pin Password (4-6 digits)",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: scrWidth * 0.028,
                                ),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(scrWidth * 0.015),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(scrWidth * 0.015),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: scrWidth * 0.7,
                            child: TextFormField(
                              controller: confirmPinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 6,
                              style: TextStyle(
                                fontSize: scrWidth * 0.033,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _changePinPassword(),
                              cursorColor: Colors.grey,
                              onChanged: (_) {
                                // Clear error when user starts typing
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                hintText: "Confirm New Pin Password",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: scrWidth * 0.028,
                                ),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(scrWidth * 0.015),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(scrWidth * 0.015),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          // Error message display
                          if (_errorMessage != null) ...[
                            SizedBox(height: 12),
                            Container(
                              width: scrWidth * 0.7,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(scrWidth * 0.015),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[700],
                                    size: scrWidth * 0.04,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        fontSize: scrWidth * 0.028,
                                        color: Colors.red[900],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(dialogContext);
                                    currentPinController.clear();
                                    newPinController.clear();
                                    confirmPinController.clear();
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                  },
                                  child: Text(
                                    "CANCEL",
                                    style: TextStyle(
                                      fontSize: scrWidth * 0.03,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                BlocBuilder<SecurityBloc, SecurityState>(
                                  builder: (context, state) {
                                    final isLoading = state is SecurityLoading;
                                    return ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: WidgetStatePropertyAll(4),
                                        backgroundColor: WidgetStatePropertyAll(colorConst.primaryColor3),
                                      ),
                                      onPressed: isLoading ? null : _changePinPassword,
                                      child: isLoading
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              "OK",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: scrWidth * 0.03,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16,bottom: 8,left: 16,right: 16),
      child: InkWell(
        onTap: () {
          changePasswordBox(false);
        },
        child: Container(
          // height: MediaQuery.of(context).size.width*0.3,
          width: MediaQuery.of(context).size.width*1,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.01),
            // color: colorConst.primaryColor,
            // color: Colors.orange.shade600,
            // image: DecorationImage(image: AssetImage(favourites[index]["image"]),fit: BoxFit.fill)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const  EdgeInsets.only(
                  left: 20,
                  right: 24,
                  top: 15,
                  bottom: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.change_circle_outlined,color: Colors.grey,size: 20,),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: SizedBox(
                            width: scrWidth*0.55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Change Pin Password",
                                  style: TextStyle(fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: MediaQuery.of(context).size.width*0.035),),
                                SizedBox(height: 8,),
                                Text(
                                  "Change Pin Password to secure transaction.",
                                  style: TextStyle(fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      fontSize: MediaQuery.of(context).size.width*0.028),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 20,
                        width: 40,
                        child: Icon(Icons.keyboard_arrow_right_outlined)),

                  ],
                ),
              ),
              // Divider(color: Colors.grey.shade300,),

            ],
          ),
        ),
      ),
    );
  }
}
