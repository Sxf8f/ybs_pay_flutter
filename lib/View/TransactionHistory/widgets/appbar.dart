import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ybs_pay/main.dart';

import '../../../core/const/color_const.dart';


class appbartransactionpage extends StatelessWidget implements PreferredSizeWidget{
  const appbartransactionpage({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: colorConst.primaryColor1),
        onPressed: () {
          Navigator.pop(context);
        },

      ),
      title: Text(

        "Transaction History",
        style: TextStyle(
          color: colorConst.primaryColor1,
          fontSize: scrWidth*0.04,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }
}

