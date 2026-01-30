import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

/// A instagram container with instagram icon and instagram launching follow us button
class instagramBox extends StatelessWidget {
  final String url;

  const instagramBox({super.key, required this.url});

  void _launchInstagram() async {
    try {
      print('Attempting to launch Instagram: $url');
      
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }
      
      final Uri instagramUri = Uri.parse(urlToLaunch);
      print('Parsed URI: $instagramUri');
      
      // Launch directly without canLaunchUrl check
      final launched = await launchUrl(
        instagramUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        print('Failed to launch Instagram URL');
      } else {
        print('Instagram launched successfully');
      }
    } catch (e) {
      print('Error launching Instagram: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launchInstagram,
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(scrWidth * 0.01),
            border: Border.all(
              color: Color(0xFFE4405F).withOpacity(0.2),
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
                    color: Color(0xFFE4405F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(scrWidth * 0.01),
                  ),
                  child: SizedBox(
                    height: scrWidth * 0.04,
                    width: scrWidth * 0.04,
                    child: SvgPicture.asset(
                      'assets/svg/insta.svg',
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
                        'Instagram',
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
