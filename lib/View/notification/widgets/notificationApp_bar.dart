
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';


/// Constructor for the app bar in the notification screen
class appbarInNotification extends StatelessWidget implements PreferredSizeWidget{
  const appbarInNotification({super.key});
  Size get preferredSize=> Size.fromHeight(kToolbarHeight);

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
        "Notifications"
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
