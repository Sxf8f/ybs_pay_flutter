import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

class signupPasswordField extends StatefulWidget {
  final TextEditingController passwordController;
  const signupPasswordField({super.key, required this.passwordController});

  @override
  State<signupPasswordField> createState() => _signupPasswordFieldState();
}

class _signupPasswordFieldState extends State<signupPasswordField> {
  bool hide=true;
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
          controller: widget.passwordController ,
          autofillHints: [AutofillHints.password],
          style: TextStyle(color: Colors.black,
              fontSize: scrWidth*0.035,
              fontWeight: FontWeight.w400),
          keyboardType: TextInputType.text,
          obscureText:hide? true:false,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          cursorColor: Colors.grey,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(10),
            suffixIcon: InkWell(
                onTap: () {
                  hide=!hide;
                  setState(() {

                  });
                },
                child: Icon(hide?Icons.visibility_off_outlined:Icons.visibility_outlined,size: 18,)),
            hintText:"Password",
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
