import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

class privacyPolicyCheckBox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const privacyPolicyCheckBox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<privacyPolicyCheckBox> createState() => _privacyPolicyCheckBoxState();
}

class _privacyPolicyCheckBoxState extends State<privacyPolicyCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          splashRadius: 10,
          value: widget.value,
          onChanged: (value) {
            widget.onChanged(value!);
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.018),
          ),
          activeColor: colorConst.primaryColor1,
        ),
        InkWell(
          onTap: () {
            widget.onChanged(!widget.value);
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: "I agree to the  ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: scrWidth * 0.03,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: scrWidth * 0.03,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
