import 'package:flutter/material.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../notification/notificationScreen.dart';
import '../../widgets/action_icon_button.dart';
import '../../widgets/spacing.dart';



/// A StatelessWidget that represents the app bar used in the add money app screen.
class appBarEditScreen extends StatelessWidget implements PreferredSizeWidget{
  const appBarEditScreen({super.key});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

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
        // widget.hospitalId
        "Edit"
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
