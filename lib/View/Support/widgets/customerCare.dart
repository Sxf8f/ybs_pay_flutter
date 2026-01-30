import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/const/color_const.dart';
import '../../../core/models/supportModels/supportModel.dart';
import '../../../main.dart';

/// Constructor for customer care contact details in a container

class customerCareBox extends StatefulWidget {
  final ContactInfo data;

  const customerCareBox({super.key, required this.data});

  @override
  State<customerCareBox> createState() => _customerCareBoxState();
}

class _customerCareBoxState extends State<customerCareBox> {
  bool customerCareDrop = false;

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(phoneUri);
  }

  void _launchWhatsApp(String phoneNumber) async {
    // Remove any dashes or spaces from phone number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[-\s]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            customerCareDrop = !customerCareDrop;
          });
        },
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(scrWidth * 0.025),
                          decoration: BoxDecoration(
                            color: colorConst.primaryColor1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              scrWidth * 0.01,
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/svg/customerService.svg',
                            height: scrWidth * 0.04,
                            width: scrWidth * 0.04,
                          ),
                        ),
                        SizedBox(width: scrWidth * 0.03),
                        Text(
                          'Customer Care',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: scrWidth * 0.033,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      customerCareDrop
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    ),
                  ],
                ),
                if (customerCareDrop) ...[
                  SizedBox(height: scrWidth * 0.04),
                  Divider(color: Theme.of(context).dividerColor),
                  SizedBox(height: scrWidth * 0.02),
                  if (widget.data.mobile.isNotEmpty)
                    _buildContactItem(
                      icon: Icons.phone_android,
                      label: 'Mobile',
                      value: widget.data.mobile,
                      onTap: () => _launchPhone(widget.data.mobile),
                    ),
                  if (widget.data.phone.isNotEmpty) ...[
                    SizedBox(height: scrWidth * 0.02),
                    _buildContactItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: widget.data.phone,
                      onTap: () => _launchPhone(widget.data.phone),
                    ),
                  ],
                  if (widget.data.whatsapp.isNotEmpty) ...[
                    SizedBox(height: scrWidth * 0.02),
                    _buildContactItem(
                      icon: Icons.chat,
                      label: 'WhatsApp',
                      value: widget.data.whatsapp,
                      onTap: () => _launchWhatsApp(widget.data.whatsapp),
                      isWhatsApp: true,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isWhatsApp = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        child: Container(
          padding: EdgeInsets.all(scrWidth * 0.03),
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(scrWidth * 0.01),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.02),
                decoration: BoxDecoration(
                  color: colorConst.primaryColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(scrWidth * 0.01),
                ),
                child: Icon(
                  icon,
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
                      label,
                      style: TextStyle(
                        fontSize: scrWidth * 0.025,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: scrWidth * 0.01),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: scrWidth * 0.031,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: scrWidth * 0.03,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
