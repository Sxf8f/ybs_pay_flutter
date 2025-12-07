import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' hide Text;

import '../../../main.dart';

/// user upi id

class upiId extends StatelessWidget {
  final upiUserId;
  const upiId({super.key, required this.upiUserId});

  @override
  Widget build(BuildContext context) {
    return Text('UPI ID : ${Uri.parse('${upiUserId}').queryParameters['pa']}',
      style: TextStyle(
        fontSize: scrWidth*0.028,
        fontWeight: FontWeight.w500
    ),);
  }
}
