import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybs_pay/core/sharedPreference/removeUserData.dart';

import '../../../core/const/color_const.dart';
import '../../../core/services/logoutServices.dart';
import '../../login/loginScreen.dart';
import '../../../main.dart';
import '../../../splashScreen.dart';

class logoutButton extends StatefulWidget {
  const logoutButton({super.key});

  @override
  State<logoutButton> createState() => _logoutButtonState();
}

class _logoutButtonState extends State<logoutButton> {
  final LogoutService logoutService = LogoutService();
  logoutShow(){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("Logout !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: scrWidth*0.04,
                      fontWeight: FontWeight.w600
                  ),),
              ),
              Text("Do you really want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: scrWidth*0.035,
                    fontWeight: FontWeight.w500
                ),),
            ],
          ),
          content: SizedBox(
            height: scrWidth*0.4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(top: 16,bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          // _logout(context);
                          removeLoginData();
                          // SharedPreferences prefs=await SharedPreferences.getInstance();
                          // prefs.remove('keyLoggedIn');
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => loginScreen()), (route) => false,);

                        },
                        child: Text("LOGOUT FROM ALL DEVICE",
                          style: TextStyle(
                              color: colorConst.primaryColor3,
                              fontSize: scrWidth*0.032,
                              fontWeight: FontWeight.w600
                          ),),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          removeLoginData();
                          // SharedPreferences prefs=await SharedPreferences.getInstance();
                          // prefs.remove('keyLoggedIn');
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => loginScreen()), (route) => false,);

                        },
                        child: Text("LOGOUT",
                          style: TextStyle(
                              color: colorConst.primaryColor3,
                              fontSize: scrWidth*0.032,
                              fontWeight: FontWeight.w600
                          ),),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Text("CANCEL",
                          style: TextStyle(
                              color: colorConst.primaryColor3,
                              fontSize: scrWidth*0.032,
                              fontWeight: FontWeight.w600
                          ),),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // color: Colors.grey.shade100,
          height: MediaQuery.of(context).size.width*0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              InkWell(
                onTap: () {
                  logoutShow();
                },
                child: Container(
                  // color: Colors.grey.shade300,
                  height: MediaQuery.of(context).size.width*0.14,
                  width: MediaQuery.of(context).size.width*0.9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(scrWidth*0.02),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 2,
                            // blurStyle: BlurStyle.outer,
                            offset: Offset(3, 3),
                            spreadRadius: 1

                        )
                      ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: scrWidth*0.07),
                        child: Text('Log Out',style: TextStyle(color: Colors.red.shade300,
                            fontWeight: FontWeight.bold,fontSize: scrWidth*0.03),),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: scrWidth*0.07),
                        child: Icon(Icons.logout,size: 20,color: Colors.red.shade300,),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
