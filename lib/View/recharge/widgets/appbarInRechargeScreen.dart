import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

/// app bar in the recharge screen
class appBarInRechargeScreen extends StatelessWidget implements PreferredSizeWidget{
  const appBarInRechargeScreen({super.key});
  @override
  Size get preferredSize=>Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios)),
      title: Text(
        "Prepaid"
        ,style: TextStyle(
          fontSize: scrWidth*0.04
      ),),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        SizedBox(
          // width: scrWidth*0.5,
          child: Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              ],
            ),
          ),
        )
      ],
    );
  }
}
