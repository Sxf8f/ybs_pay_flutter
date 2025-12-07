import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';


/// container button for update user details.
class updateProfileButton extends StatelessWidget {

  const updateProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14,right: 16,bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: Colors.white,
            child: InkWell(
              // onTap: updateUserDetails,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      colorConst.primaryColor3,
                      colorConst.primaryColor3
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width*0.03,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
