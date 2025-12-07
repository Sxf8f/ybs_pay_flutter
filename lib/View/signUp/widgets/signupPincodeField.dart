import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

class signupPinCodeField extends StatelessWidget {
  final TextEditingController pinCodeController;
  const signupPinCodeField({super.key, required this.pinCodeController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: MediaQuery.of(context).size.width*0.85,
        height: MediaQuery.of(context).size.width*0.11,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: TextFormField(
          controller:pinCodeController ,
          style: TextStyle(color: Colors.black,
              fontSize: scrWidth*0.035,
              fontWeight: FontWeight.w400),
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          cursorColor: Colors.grey,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(10),
            hintText:"Pin code",
            hintStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
                fontSize: scrWidth*0.03
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                borderSide: BorderSide(color: Colors.grey.shade400)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                borderSide: BorderSide(
                  color: Colors.blue,
                )
            ),
          ),
        ),
      ),
    );
  }
}
