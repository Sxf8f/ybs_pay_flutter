import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../../navigationPage.dart';

/// done button in confirm status screen
class doneButtonInConfirmStatus extends StatelessWidget {
  const doneButtonInConfirmStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => navigationPage(initialIndex: 0,),));
      },
      child: Container(
        height: scrWidth*0.13,
        width: scrWidth*0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scrWidth*0.04),
            color: colorConst.primaryColor3
        ),
        child: Center(child: Text("Done",style: TextStyle(color: colorConst.white,fontWeight: FontWeight.bold,fontSize: scrWidth*0.035),)),
      ),
    );
  }
}
