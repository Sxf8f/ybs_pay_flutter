import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../../navigationPage.dart';

class signupButton extends StatelessWidget {
  final Future<void> Function() onChanged;
  const signupButton({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: MediaQuery.of(context).size.width*0.48,
          constraints: BoxConstraints(minWidth: 120, minHeight: 45),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorConst.primaryColor1,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            'Sign up',
            style: TextStyle(
              fontSize: scrWidth*0.043,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
