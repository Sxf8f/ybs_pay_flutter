import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

/// A twitter X container with X icon and X launching follow us button
class twitterXBox extends StatelessWidget {
  final String url;

  const twitterXBox({super.key, required this.url});

  void _launchTwitterX() async {
    try {
      print('Attempting to launch Twitter/X: $url');
      
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }
      
      final Uri twitterUri = Uri.parse(urlToLaunch);
      print('Parsed URI: $twitterUri');
      
      // Launch directly without canLaunchUrl check
      final launched = await launchUrl(
        twitterUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        print('Failed to launch Twitter/X URL');
      } else {
        print('Twitter/X launched successfully');
      }
    } catch (e) {
      print('Error launching Twitter/X: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launchTwitterX,
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(scrWidth * 0.01),
            border: Border.all(
              color: Theme.of(context).dividerColor,
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
                    color: scheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(scrWidth * 0.01),
                  ),
                  child: SizedBox(
                    height: scrWidth * 0.04,
                    width: scrWidth * 0.04,
                    child: SvgPicture.asset(
                      'assets/svg/x.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: scrWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'X (Twitter)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: scrWidth * 0.033,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: scrWidth * 0.01),
                      Text(
                        'Follow Us',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: scrWidth * 0.028,
                          color: Theme.of(context).textTheme.bodySmall?.color,
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
