import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';


/// constructor for the recharge amount field
class enterAmountField extends StatelessWidget {
  final TextEditingController amountController;
  const enterAmountField({super.key, required this.amountController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.88,
      height: MediaQuery.of(context).size.width*0.12,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.02),
          border: Border.all(color: Colors.grey)
      ),
      child: Container(
        width: MediaQuery.of(context).size.width*0.9,
        height: MediaQuery.of(context).size.width*0.1,
        child: TextFormField(
          controller: amountController,
          style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w400),
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          cursorColor: Colors.grey,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.all(10),
            hintText:"Enter Amount",
            hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: scrWidth*0.03
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
