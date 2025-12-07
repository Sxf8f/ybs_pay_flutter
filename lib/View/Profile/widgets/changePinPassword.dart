import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

class changePinPassword extends StatefulWidget {
  const changePinPassword({super.key});

  @override
  State<changePinPassword> createState() => _changePinPasswordState();
}

class _changePinPasswordState extends State<changePinPassword> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  changePasswordBox(bool isPassword){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  isPassword?
                  "Change Password":
                  "Change Pin Password"
                  ,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: scrWidth*0.035,
                      fontWeight: FontWeight.w600,
                      color: colorConst.primaryColor3
                  ),),
              ),

            ],
          ),
          content: SizedBox(
            height: scrWidth*0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                SizedBox(
                  width: scrWidth*0.7,
                  child: TextFormField(
                    controller: currentPasswordController,
                    style: TextStyle(fontSize: scrWidth*0.033,color: Colors.black,fontWeight: FontWeight.w400),
                    textInputAction: TextInputAction.next,
                    // autofocus: true,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText:"Current Password",
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: scrWidth*0.028
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(scrWidth * 0.015),
                            borderSide:
                            BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(scrWidth * 0.015),
                            borderSide:
                            BorderSide(color: Colors.grey))),
                  ),
                ),
                SizedBox(height: 10,),

                SizedBox(
                  width: scrWidth*0.7,
                  child: TextFormField(
                    controller: newPasswordController,
                    style: TextStyle(fontSize: scrWidth*0.033,color: Colors.black,fontWeight: FontWeight.w400),
                    textInputAction: TextInputAction.next,
                    // autofocus: true,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText:isPassword?"New Password":"New Pin Password",
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: scrWidth*0.028
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(scrWidth * 0.015),
                            borderSide:
                            BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(scrWidth * 0.015),
                            borderSide:
                            BorderSide(color: Colors.grey))),
                  ),
                ),
                SizedBox(height: 10,),

                SizedBox(
                  width: scrWidth*0.7,
                  child: TextFormField(
                    controller: confirmNewPasswordController,
                    style: TextStyle(fontSize: scrWidth*0.033,color: Colors.black,fontWeight: FontWeight.w400),
                    textInputAction: TextInputAction.next,
                    // autofocus: true,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText:isPassword?"Confirm New Password":"Confirm New Pin Password",
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: scrWidth*0.028
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(scrWidth * 0.015),
                            borderSide:
                            BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(scrWidth * 0.015),
                            borderSide:
                            BorderSide(color: Colors.grey))),
                  ),
                ),
                SizedBox(height: 10,),




                Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Text("CANCEL",
                          style: TextStyle(
                            // color: colorConst.primaryColor3,
                              fontSize: scrWidth*0.03,
                              fontWeight: FontWeight.w300
                          ),),
                      ),

                      ElevatedButton(
                          style: ButtonStyle(
                            elevation: WidgetStatePropertyAll(4),
                            backgroundColor: WidgetStatePropertyAll(colorConst.primaryColor3),
                          ),
                          onPressed: () {
                            Navigator.pop(context);

                          }, child: Text(
                        "OK",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: scrWidth*0.03,
                            fontWeight: FontWeight.w600
                        ),)),

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
    return Padding(
      padding: const EdgeInsets.only(top: 16,bottom: 8,left: 16,right: 16),
      child: InkWell(
        onTap: () {
          changePasswordBox(false);
        },
        child: Container(
          // height: MediaQuery.of(context).size.width*0.3,
          width: MediaQuery.of(context).size.width*1,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.01),
            // color: colorConst.primaryColor,
            // color: Colors.orange.shade600,
            // image: DecorationImage(image: AssetImage(favourites[index]["image"]),fit: BoxFit.fill)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const  EdgeInsets.only(
                  left: 20,
                  right: 24,
                  top: 15,
                  bottom: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.change_circle_outlined,color: Colors.grey,size: 20,),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: SizedBox(
                            width: scrWidth*0.55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Change Pin Password",
                                  style: TextStyle(fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: MediaQuery.of(context).size.width*0.035),),
                                SizedBox(height: 8,),
                                Text(
                                  "Change Pin Password to secure transaction.",
                                  style: TextStyle(fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      fontSize: MediaQuery.of(context).size.width*0.028),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 20,
                        width: 40,
                        child: Icon(Icons.keyboard_arrow_right_outlined)),

                  ],
                ),
              ),
              // Divider(color: Colors.grey.shade300,),

            ],
          ),
        ),
      ),
    );
  }
}
