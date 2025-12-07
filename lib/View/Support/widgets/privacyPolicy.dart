import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';


/// Privacy policy and terms & conditions

class privacyPolicyTermsConditionsBox extends StatelessWidget {
  const privacyPolicyTermsConditionsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.grey.shade300,
      // height: MediaQuery.of(context).size.width*0.14,
      width: MediaQuery.of(context).size.width*0.92,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(scrWidth*0.015),
          color: Colors.white,
          // border: Border.all(
          //   color: Colors.grey.shade300,
          // ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 2,
                // blurStyle: BlurStyle.outer,
                offset: Offset(0, 0),
                spreadRadius: 1

            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 16),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: scrWidth*0.07),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Privacy Policy',style: TextStyle(
                          color: colorConst.primaryColor1,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: colorConst.primaryColor1,
                          fontSize: scrWidth*0.035),),
                      SizedBox(width: 20,),
                      Text('Terms & Conditions',style: TextStyle(
                          color: colorConst.primaryColor1,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: colorConst.primaryColor1,
                          fontSize: scrWidth*0.035),),
                    ],
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
