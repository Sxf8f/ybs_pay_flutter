import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/services/biometric_service.dart';
import '../../core/const/color_const.dart';
import '../../main.dart';

/// Biometric lock screen that appears on app opening
/// Similar to Google Pay's authentication flow
class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback? onCancel;

  const BiometricLockScreen({
    Key? key,
    required this.onAuthenticated,
    this.onCancel,
  }) : super(key: key);

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _biometricTypeName = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadBiometricType();
    // Automatically trigger authentication when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _loadBiometricType() async {
    final typeName = await BiometricService.getBiometricTypeName();
    setState(() {
      _biometricTypeName = typeName;
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final authenticated = await BiometricService.authenticate(
        reason: 'Authenticate to access ${_biometricTypeName}',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (authenticated) {
        // Authentication successful
        if (mounted) {
          widget.onAuthenticated();
        }
      } else {
        // Authentication failed or cancelled
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication failed. Please try again.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Authentication error: ${e.toString()}';
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorConst.lightBlue,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bgtask.png"),
              fit: BoxFit.cover,
              opacity: 0.06,
            ),
            color: Colors.white,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo or Icon
                  Container(
                    width: scrWidth * 0.25,
                    height: scrWidth * 0.25,
                    decoration: BoxDecoration(
                      color: colorConst.primaryColor1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: scrWidth * 0.15,
                      color: colorConst.primaryColor1,
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  // Title
                  Text(
                    'Unlock App',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'Use $_biometricTypeName to unlock',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  
                  // Error message if any
                  if (_hasError)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Authenticate button
                  if (!_isAuthenticating)
                    ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: Icon(Icons.fingerprint, size: 24),
                      label: Text(
                        'Authenticate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorConst.primaryColor1,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  
                  // Loading indicator
                  if (_isAuthenticating)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorConst.primaryColor1,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Authenticating...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  
                  SizedBox(height: 24),
                  
                  // Cancel button (optional)
                  if (widget.onCancel != null && !_isAuthenticating)
                    TextButton(
                      onPressed: widget.onCancel,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 40),
                  
                  // Info text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'If $_biometricTypeName is not available, you will be prompted to use your device PIN, password, or pattern.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
