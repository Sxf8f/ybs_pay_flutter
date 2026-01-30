import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/const/color_const.dart';
import '../../../core/repository/legalDocumentsRepository/legalDocumentsRepo.dart';
import '../../../main.dart';

class privacyPolicyCheckBox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const privacyPolicyCheckBox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<privacyPolicyCheckBox> createState() => _privacyPolicyCheckBoxState();
}

class _privacyPolicyCheckBoxState extends State<privacyPolicyCheckBox> {
  final LegalDocumentsRepository _repository = LegalDocumentsRepository();
  String? _termsConditionsUrl;
  String? _privacyPolicyUrl;
  bool _termsConditionsEnabled = false;
  bool _privacyPolicyEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLegalDocuments();
  }

  Future<void> _fetchLegalDocuments() async {
    try {
      final response = await _repository.fetchLegalDocuments();
      setState(() {
        _termsConditionsUrl = response.termsConditions.url;
        _privacyPolicyUrl = response.privacyPolicy.url;
        _termsConditionsEnabled = response.termsConditions.enabled;
        _privacyPolicyEnabled = response.privacyPolicy.enabled;
        _isLoading = false;
      });
    } catch (e) {
      print('⚠️ [PRIVACY_POLICY] Error fetching legal documents: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty || url == 'null') return;
    
    try {
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }
      
      final Uri uri = Uri.parse(urlToLaunch);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        print('⚠️ [PRIVACY_POLICY] Failed to launch URL: $url');
      }
    } catch (e) {
      print('❌ [PRIVACY_POLICY] Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          splashRadius: 10,
          value: widget.value,
          onChanged: (value) {
            widget.onChanged(value!);
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.018),
          ),
          activeColor: colorConst.primaryColor1,
        ),
        Expanded(
          child: _isLoading
              ? Text(
                  "I agree to the Terms & Conditions",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: scrWidth * 0.03,
                    fontWeight: FontWeight.w300,
                  ),
                )
              : Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "I agree to the  ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: scrWidth * 0.03,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      // Terms & Conditions link
                      if (_termsConditionsEnabled &&
                          _termsConditionsUrl != null &&
                          _termsConditionsUrl!.isNotEmpty)
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: scrWidth * 0.03,
                            decoration: TextDecoration.underline,
                            color: colorConst.primaryColor1,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchUrl(_termsConditionsUrl!),
                        )
                      else
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: scrWidth * 0.03,
                            color: Colors.black,
                          ),
                        ),
                      // Privacy Policy link (if Terms & Conditions is also available)
                      if (_termsConditionsEnabled &&
                          _termsConditionsUrl != null &&
                          _termsConditionsUrl!.isNotEmpty &&
                          _privacyPolicyEnabled &&
                          _privacyPolicyUrl != null &&
                          _privacyPolicyUrl!.isNotEmpty)
                        TextSpan(
                          text: ' and ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: scrWidth * 0.03,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      if (_privacyPolicyEnabled &&
                          _privacyPolicyUrl != null &&
                          _privacyPolicyUrl!.isNotEmpty)
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: scrWidth * 0.03,
                            decoration: TextDecoration.underline,
                            color: colorConst.primaryColor1,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchUrl(_privacyPolicyUrl!),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
