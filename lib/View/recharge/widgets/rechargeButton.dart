import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';



/// constructor for recharge button
class rechargeButton extends StatelessWidget {
  const rechargeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: scrWidth*1,
      height: 60,
      color: colorConst.primaryColor3,
      child: Center(child: Text('Recharge',style: TextStyle(
          color: Colors.white,
          fontSize: scrWidth*0.038 ,
          fontWeight: FontWeight.w600
      ),)),
    );
  }
}
