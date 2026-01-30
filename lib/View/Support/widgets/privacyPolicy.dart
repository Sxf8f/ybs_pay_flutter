import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

/// Privacy policy and terms & conditions

class privacyPolicyTermsConditionsBox extends StatelessWidget {
  final String privacyPolicyUrl;
  final String termsConditionsUrl;
  final bool privacyPolicyEnabled;
  final bool termsConditionsEnabled;

  const privacyPolicyTermsConditionsBox({
    super.key,
    required this.privacyPolicyUrl,
    required this.termsConditionsUrl,
    required this.privacyPolicyEnabled,
    required this.termsConditionsEnabled,
  });

  void _launchUrl(String url) async {
    if (url.isEmpty) return;
    
    try {
      print('Attempting to launch URL: $url');
      
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }
      
      final Uri uri = Uri.parse(urlToLaunch);
      print('Parsed URI: $uri');
      
      // Launch directly without canLaunchUrl check
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        print('Failed to launch URL');
      } else {
        print('URL launched successfully');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Widget _buildLegalLink({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // This helper doesn't get BuildContext directly, use theme from InkWell builder context below.
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(scrWidth * 0.01),
          child: Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              return Container(
                padding: EdgeInsets.all(scrWidth * 0.03),
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(scrWidth * 0.01),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: colorConst.primaryColor1,
                      size: scrWidth * 0.04,
                    ),
                    SizedBox(height: scrWidth * 0.02),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorConst.primaryColor1,
                        fontWeight: FontWeight.w600,
                        fontSize: scrWidth * 0.029,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        border: Border.all(
          color: colorConst.primaryColor1.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(scrWidth * 0.04),
        child: Row(
          children: [
            if (privacyPolicyEnabled && privacyPolicyUrl.isNotEmpty)
              _buildLegalLink(
                title: 'Privacy Policy',
                icon: Icons.privacy_tip,
                onTap: () => _launchUrl(privacyPolicyUrl),
              ),
            if (privacyPolicyEnabled &&
                privacyPolicyUrl.isNotEmpty &&
                termsConditionsEnabled &&
                termsConditionsUrl.isNotEmpty)
              SizedBox(width: scrWidth * 0.03),
            if (termsConditionsEnabled && termsConditionsUrl.isNotEmpty)
              _buildLegalLink(
                title: 'Terms & Conditions',
                icon: Icons.description,
                onTap: () => _launchUrl(termsConditionsUrl),
              ),
          ],
        ),
      ),
    );
  }
}
