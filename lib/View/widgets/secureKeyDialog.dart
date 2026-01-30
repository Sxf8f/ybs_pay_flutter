import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/const/color_const.dart';
import '../../main.dart';

/// Secure Key Input Dialog
/// Shows a dialog to enter secure key (pin password) for transactions
class SecureKeyDialog extends StatefulWidget {
  final String title;
  final String message;

  const SecureKeyDialog({
    Key? key,
    this.title = 'Enter Secure Key',
    this.message = 'Please enter your secure key (pin password) to continue',
  }) : super(key: key);

  @override
  State<SecureKeyDialog> createState() => _SecureKeyDialogState();
}

class _SecureKeyDialogState extends State<SecureKeyDialog> {
  final TextEditingController _secureKeyController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _secureKeyController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final secureKey = _secureKeyController.text.trim();
    
    if (secureKey.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your secure key';
      });
      return;
    }

    if (secureKey.length < 4 || secureKey.length > 6) {
      setState(() {
        _errorMessage = 'Secure key must be 4-6 digits';
      });
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(secureKey)) {
      setState(() {
        _errorMessage = 'Secure key must contain only numbers';
      });
      return;
    }

    // Valid secure key - close dialog and return it
    Navigator.of(context).pop(secureKey);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(scrWidth * 0.04),
      ),
      child: Padding(
        padding: EdgeInsets.all(scrWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: scrWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: scrWidth * 0.05),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: scrWidth * 0.03),

            // Message
            Text(
              widget.message,
              style: TextStyle(
                fontSize: scrWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: scrWidth * 0.05),

            // Secure Key Input Field
            TextField(
              controller: _secureKeyController,
              obscureText: _obscureText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: 'Secure Key',
                hintText: 'Enter 4-6 digit secure key',
                prefixIcon: Icon(Icons.lock_outline, color: colorConst.primaryColor1),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                  borderSide: BorderSide(color: colorConst.primaryColor1, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                errorText: _errorMessage,
              ),
              onChanged: (value) {
                // Clear error when user starts typing
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              onSubmitted: (_) => _validateAndSubmit(),
            ),
            SizedBox(height: scrWidth * 0.04),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: scrWidth * 0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(scrWidth * 0.02),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: scrWidth * 0.035,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: scrWidth * 0.03),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: scrWidth * 0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(scrWidth * 0.02),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: scrWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

