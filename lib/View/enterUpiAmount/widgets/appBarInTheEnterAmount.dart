import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



/// app bar in the enter amount screen
class appBarInEnterAmountScreen extends StatelessWidget implements PreferredSizeWidget{
  const appBarInEnterAmountScreen({super.key});
  @override

  Size get preferredSize=> Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.close)),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16,left: 16),
          child: Icon(Icons.report,color: Colors.grey.shade600,),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(Icons.more_vert,color: Colors.grey.shade600,),
        ),
      ],
      // automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
    );
  }
}
