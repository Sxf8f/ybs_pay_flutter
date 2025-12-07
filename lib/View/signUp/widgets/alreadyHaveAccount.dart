import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ybs_pay/View/login/loginScreen.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

class alreadyHaveAccount extends StatelessWidget {
  const alreadyHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account?",
            style: TextStyle(
                fontSize: scrWidth*0.033,
                fontWeight: FontWeight.w400,
                color: Colors.black
            ),),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginScreen(),));
            },
            child: Text("  Sign in",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: scrWidth*0.038,
                  color: colorConst.primaryColor1
              ),),
          )
        ],),
    );
  }
}
