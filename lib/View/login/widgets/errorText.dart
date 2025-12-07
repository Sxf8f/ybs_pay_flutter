import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

class errorText extends StatelessWidget {
  final errorMessage;
  const errorText({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(errorMessage != null?errorMessage!:'', style: TextStyle(
          color: Colors.red,
          fontSize: scrWidth*0.033
      )),
    );
  }
}
