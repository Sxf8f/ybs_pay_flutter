import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

class signInText extends StatelessWidget {
  const signInText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.75,
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14,bottom: 8),
            child: Text("Sign In",style: TextStyle(
                fontSize: scrWidth*0.045,
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width*0.1,
                right: MediaQuery.of(context).size.width*0.1,
                top: scrWidth*0.0),
            child: Text("Please enter your login id and password to sign in.",style: TextStyle(
                fontSize: scrWidth*0.032,
                color: Colors.black,
                fontWeight: FontWeight.w400
            ),textAlign: TextAlign.center,),
          ),
        ],
      ),
    );
  }
}
