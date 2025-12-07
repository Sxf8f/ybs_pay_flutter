import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';


/// constructor for the prepaid number field
class prepaidNumberField extends StatelessWidget {
  final TextEditingController prepaidNumberController;
  const prepaidNumberField({super.key, required this.prepaidNumberController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0,left: 8),
      child: Container(
        width: MediaQuery.of(context).size.width*0.88,
        // height: scrWidth*0.23,
        // color: Colors.grey.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                      // controller: amountController,
                      style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w400),
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.all(10),
                        hintText:"Enter Prepaid Number",
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: scrWidth*0.03
                        ),
                        // border: UnderlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: Colors.grey
                        //   )
                        // ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
