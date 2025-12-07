import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ybs_pay/View/Support/widgets/accouts&finance.dart';
import 'package:ybs_pay/View/Support/widgets/addressBox.dart';
import 'package:ybs_pay/View/Support/widgets/bankDetails.dart';
import 'package:ybs_pay/View/Support/widgets/customerCare.dart';
import 'package:ybs_pay/View/Support/widgets/facebook.dart';
import 'package:ybs_pay/View/Support/widgets/instagram.dart';
import 'package:ybs_pay/View/Support/widgets/mobileAndDthTollFree.dart';
import 'package:ybs_pay/View/Support/widgets/privacyPolicy.dart';
import 'package:ybs_pay/View/Support/widgets/websiteBox.dart';
import 'package:ybs_pay/View/Support/widgets/x.dart';
import 'package:ybs_pay/View/widgets/app_bar.dart';

import '../../core/const/color_const.dart';
import '../../main.dart';

class supportsScreen extends StatefulWidget {
  const supportsScreen({super.key});

  @override
  State<supportsScreen> createState() => _supportsScreenState();
}

class _supportsScreenState extends State<supportsScreen> {
  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch phone dialer');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Contact Us',style: TextStyle(
                      fontSize: scrWidth*0.036,
                      fontWeight: FontWeight.w600
                  ),)
                ],
              ),
            ),
            SizedBox(height: scrWidth*0.04,),

            /// Customer Care
            customerCareBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Accounts and Finance
            accountsFinanceBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Facebook
            facebookBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Instagram
            instagramBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Twitter X
            twitterXBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Website
            websiteBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Address
            addressBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Mobile toll free and dth toll free
            mobileAndDthTollFreeBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Bank Details
            bankDetailsBox(),
            SizedBox(height: scrWidth*0.04,),

            /// Privacy Policy
            privacyPolicyTermsConditionsBox(),
            SizedBox(height: scrWidth*0.3,),
          ],
        ),
      ),
    );
  }
}
