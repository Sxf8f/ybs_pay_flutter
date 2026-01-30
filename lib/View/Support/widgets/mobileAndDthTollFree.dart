import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/const/color_const.dart';
import '../../../core/models/supportModels/supportModel.dart';
import '../../../main.dart';

/// Mobile and dth toll free container with alert dialogue with contact number

class mobileAndDthTollFreeBox extends StatefulWidget {
  final List<TollFreeNumber> mobileTollFree;
  final List<TollFreeNumber> dthTollFree;

  const mobileAndDthTollFreeBox({
    super.key,
    required this.mobileTollFree,
    required this.dthTollFree,
  });

  @override
  State<mobileAndDthTollFreeBox> createState() =>
      _mobileAndDthTollFreeBoxState();
}

class _mobileAndDthTollFreeBoxState extends State<mobileAndDthTollFreeBox> {
  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(phoneUri);
  }

  void showTollFreeDialogue(bool isMobileToll) {
    final tollFreeList =
        isMobileToll ? widget.mobileTollFree : widget.dthTollFree;

    if (tollFreeList.isEmpty) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 7),
                child: Text(
                  isMobileToll ? "Prepaid Support" : "DTH Support",
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
            height: scrWidth * 0.38,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 18),
                  ...tollFreeList.map((tollFree) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Text(
                            tollFree.operatorName,
                            style: TextStyle(
                              fontSize: scrWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              _launchPhone(tollFree.phoneNumber);
                            },
                            child: Text(
                              tollFree.phoneNumber,
                              style: TextStyle(
                                fontSize: scrWidth * 0.035,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                                color: colorConst.primaryColor1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox.shrink(),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Done",
                            style: TextStyle(
                              fontSize: scrWidth * 0.03,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTollFreeCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(scrWidth * 0.01),
            border: Border.all(
              color: colorConst.primaryColor1.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                    icon,
                    color: colorConst.primaryColor1,
                    size: scrWidth * 0.04,
                  ),
                ),
                SizedBox(width: scrWidth * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth * 0.033,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: scrWidth * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Mobile Toll Free
        if (widget.mobileTollFree.isNotEmpty)
          _buildTollFreeCard(
            title: 'Mobile Toll Free',
            icon: Icons.phone_android,
            onTap: () => showTollFreeDialogue(true),
          ),

        if (widget.mobileTollFree.isNotEmpty) SizedBox(height: scrWidth * 0.04),

        /// DTH Toll free
        if (widget.dthTollFree.isNotEmpty)
          _buildTollFreeCard(
            title: 'DTH Toll Free',
            icon: Icons.tv_outlined,
            onTap: () => showTollFreeDialogue(false),
          ),
      ],
    );
  }
}
