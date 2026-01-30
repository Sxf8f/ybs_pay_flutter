import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

/// A website container with website icon and website launching text inkwell
class websiteBox extends StatelessWidget {
  final String url;

  const websiteBox({super.key, required this.url});

  void _launchWebsite(BuildContext context) async {
    try {
      print('Attempting to launch website: $url');
      
      // Ensure URL has a scheme
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }
      
      final Uri websiteUri = Uri.parse(urlToLaunch);
      print('Parsed URI: $websiteUri');
      
      // For HTTP/HTTPS URLs, try launching directly without canLaunchUrl check
      // canLaunchUrl can return false for generic URLs even though they can be opened
      final launched = await launchUrl(
        websiteUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        print('Failed to launch URL');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open website. Please check the URL.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Website launched successfully');
      }
    } catch (e) {
      print('Error launching website: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening website: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchWebsite(context),
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        child: Container(
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
                Container(
                  padding: EdgeInsets.all(scrWidth * 0.025),
                  decoration: BoxDecoration(
                    color: colorConst.primaryColor1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(scrWidth * 0.01),
                  ),
                  child: Icon(
                    Icons.public,
                    color: colorConst.primaryColor1,
                    size: scrWidth * 0.04,
                  ),
                ),
                SizedBox(width: scrWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Website',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: scrWidth * 0.033,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: scrWidth * 0.01),
                      Text(
                        'Open Website',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: scrWidth * 0.028,
                          color: colorConst.primaryColor1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                  size: scrWidth * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
