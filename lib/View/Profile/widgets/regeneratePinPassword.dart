import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/securityBloc/securityBloc.dart';
import '../../../core/bloc/securityBloc/securityEvent.dart';
import '../../../core/bloc/securityBloc/securityState.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';

class RegeneratePinPassword extends StatelessWidget {
  const RegeneratePinPassword({super.key});

  void _showRegenerateDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<SecurityBloc>(),
          child: BlocListener<SecurityBloc, SecurityState>(
            listener: (context, state) {
              if (state is SecureKeyRegenerated) {
                Navigator.pop(dialogContext);
                _showResultDialog(context, state.response);
                // Refresh double factor status
                context.read<SecurityBloc>().add(FetchDoubleFactorStatus());
              } else if (state is SecurityError) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<SecurityBloc, SecurityState>(
              builder: (context, state) {
                final isLoading = state is SecurityLoading;
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Regenerate Pin Password",
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading) ...[
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorConst.primaryColor3,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Regenerating secure key...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: scrWidth * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.warning_amber_rounded,
                              size: scrWidth * 0.08,
                              color: Colors.orange,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "A new secure key will be generated and sent to your registered phone number via SMS and email.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: scrWidth * 0.03,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Do you want to continue?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: scrWidth * 0.032,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: isLoading
                      ? []
                      : [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              "CANCEL",
                              style: TextStyle(
                                fontSize: scrWidth * 0.03,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              elevation: WidgetStatePropertyAll(4),
                              backgroundColor: WidgetStatePropertyAll(
                                colorConst.primaryColor3,
                              ),
                            ),
                            onPressed: () {
                              context.read<SecurityBloc>().add(RegenerateSecureKey());
                            },
                            child: Text(
                              "REGENERATE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scrWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, response) {
    final secureKeySent = response.secureKeySent;
    final newSecureKey = response.newSecureKey;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scrWidth * 0.02),
          ),
          title: Column(
            children: [
              Icon(
                secureKeySent ? Icons.check_circle : Icons.warning_amber_rounded,
                size: scrWidth * 0.12,
                color: secureKeySent ? Colors.green : Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                "Secure Key Regenerated",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: scrWidth * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: scrWidth * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
 
                if (!secureKeySent && newSecureKey != null) ...[
                  // SizedBox(height: 20),
                  Text('Your new secure key is sent to your registered phone number & email.',style: TextStyle(
                    fontSize: scrWidth * 0.032,
                    color: Colors.grey[700],
                  ),)
                ],
                if (response.warning != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(scrWidth * 0.02),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            response.warning!,
                            style: TextStyle(
                              fontSize: scrWidth * 0.028,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (!secureKeySent && newSecureKey != null)
  
            ElevatedButton(
              style: ButtonStyle(
                elevation: WidgetStatePropertyAll(4),
                backgroundColor: WidgetStatePropertyAll(colorConst.primaryColor3),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: scrWidth * 0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
      child: InkWell(
        onTap: () {
          _showRegenerateDialog(context);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
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
                        Icon(
                          Icons.refresh_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: SizedBox(
                            width: scrWidth * 0.55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Regenerate Pin Password",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Forgot your pin? Regenerate and receive via WhatsApp.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: MediaQuery.of(context).size.width * 0.028,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                      width: 40,
                      child: Icon(Icons.keyboard_arrow_right_outlined),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

