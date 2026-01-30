import 'package:flutter/material.dart';
import '../../../core/repository/authRepository/forgotPasswordRepo.dart';
import '../../../core/models/authModels/forgotPasswordModel.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailOrPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone number is required';
    }

    final trimmedValue = value.trim();

    // Check if it's an email (contains @)
    if (trimmedValue.contains('@')) {
      // Basic email validation
      if (!trimmedValue.contains('.') || trimmedValue.length < 5) {
        return 'Please enter a valid email address';
      }
    } else {
      // Phone validation - should be numeric (after removing spaces, dashes, +)
      final cleanedPhone = trimmedValue.replaceAll(RegExp(r'[\s\-+]'), '');
      if (cleanedPhone.isEmpty || !RegExp(r'^\d+$').hasMatch(cleanedPhone)) {
        return 'Please enter a valid phone number';
      }
      if (cleanedPhone.length < 10) {
        return 'Phone number must be at least 10 digits';
      }
    }

    return null;
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ForgotPasswordRepository();
      final response = await repository.forgotPassword(
        _emailOrPhoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        // Show success dialog
        _showSuccessDialog(response);
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to reset password';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }

  void _showSuccessDialog(ForgotPasswordResponse response) {
    final deliveryMethod = response.sentVia == 'email'
        ? 'email'
        : 'phone number';
    final contact = response.contact ?? 'your registered contact';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorConst.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Password Sent',
                style: TextStyle(
                  fontSize: scrWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response.message ??
                  'Your new password has been sent successfully.',
              style: TextStyle(
                fontSize: scrWidth * 0.035,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorConst.primaryColor1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    response.sentVia == 'email' ? Icons.email : Icons.phone,
                    color: colorConst.primaryColor1,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Check your $deliveryMethod:\n$contact',
                      style: TextStyle(
                        fontSize: scrWidth * 0.032,
                        fontWeight: FontWeight.w500,
                        color: colorConst.primaryColor1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close success dialog
              Navigator.of(context).pop(); // Close forgot password dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: colorConst.primaryColor1,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: scrWidth * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(scrWidth * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.lock_reset,
                    color: colorConst.primaryColor1,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: scrWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Description
              Text(
                'Enter your registered email address or phone number to receive a new password.',
                style: TextStyle(
                  fontSize: scrWidth * 0.032,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),

              // Email/Phone Input Field
              TextFormField(
                controller: _emailOrPhoneController,
                decoration: InputDecoration(
                  hintText: 'Email or Phone Number',
                  labelText: 'Email or Phone Number',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorConst.primaryColor1,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red.shade300),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleForgotPassword(),
                validator: _validateInput,
                enabled: !_isLoading,
              ),
              SizedBox(height: 12),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: scrWidth * 0.03,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: scrWidth * 0.035,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Send Password',
                            style: TextStyle(
                              fontSize: scrWidth * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
