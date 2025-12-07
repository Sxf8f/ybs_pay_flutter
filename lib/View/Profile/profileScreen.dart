import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybs_pay/View/Profile/widgets/addressDetails.dart';
import 'package:ybs_pay/View/Profile/widgets/changePassword.dart';
import 'package:ybs_pay/View/Profile/widgets/changePinPassword.dart';
import 'package:ybs_pay/View/Profile/widgets/doubleFactorButton.dart';
import 'package:ybs_pay/View/Profile/widgets/logOut.dart';
import 'package:ybs_pay/View/Profile/widgets/prepaidWalletBalance.dart';
import 'package:ybs_pay/View/Profile/widgets/profileImage&Name.dart';
import 'package:ybs_pay/View/Profile/widgets/realApiButton.dart';
import 'package:ybs_pay/View/Profile/widgets/userDetails.dart';
import 'package:ybs_pay/View/widgets/app_bar.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key});

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:appBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 15,),
            ///Profile image, name and edit icon
            profileImageAndIcon(),

            /// Prepaid wallet balance container
            prepaidWalletBalance(),

            /// User details
            userDetails(),
            SizedBox(height: 16,),

            /// Address Details
            addressDetails(),
            SizedBox(height: 16,),

            /// Double factor button
            doubleFactorApi(),
            SizedBox(height: 0,),

            /// Real API button
            realApiButton(),
            SizedBox(height: 0,),


            /// change password button
            changePassword(),
            SizedBox(height: 0,),


            ///change Pin Password
            changePinPassword(),


            /// logout
            logoutButton(),
            SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }
}




