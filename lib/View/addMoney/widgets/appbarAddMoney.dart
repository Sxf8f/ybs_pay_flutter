import 'package:flutter/material.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../notification/notificationScreen.dart';
import '../../widgets/action_icon_button.dart';
import '../../widgets/spacing.dart';



/// A StatelessWidget that represents the app bar used in the add money app screen.


class appBarAddMoney extends StatelessWidget implements PreferredSizeWidget{
  const appBarAddMoney({super.key});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      iconTheme: IconThemeData(
        color:  Colors.black,
      ),
      // backgroundColor: _isNightMode?Colors.black: Colors.white,
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width*1,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0,left: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  // color: Colors.grey,
                  //   width: MediaQuery.of(context).size.width*0.07,
                    height: MediaQuery.of(context).size.width*0.05,
                    child: Row(
                      children: [
                        Image.asset("assets/images/ybs.jpeg"),
                      ],
                    )),
                Row(
                  children: [
                    Icon(Icons.autorenew_sharp,color: colorConst.primaryColor1,),
                    SizedBox(width: scrWidth*0.02,),

                    Stack(
                      children: [

                        SizedBox(
                          height: 50,
                          width: 50,
                          child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => notificationScreen(),));
                              },
                              child: Icon(Icons.notifications,size: 30,color: colorConst.primaryColor1,)),
                        ),

                        Positioned(
                          top: scrWidth * 0.025,
                          right: scrWidth * 0.015,
                          child: CircleAvatar(
                            backgroundColor: colorConst.primaryColor3,
                            radius: scrWidth * 0.025,
                            child: Center(
                              child: Text(
                                '6',
                                // meatDetailCollection.length.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: scrWidth * 0.03),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),

      ],
    );
  }
}
