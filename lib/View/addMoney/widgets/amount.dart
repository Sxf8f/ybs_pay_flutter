import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';




/// Constructor for amount entering text field in adding money screen




class enterAmount extends StatefulWidget {
  const enterAmount({super.key});

  @override
  State<enterAmount> createState() => _enterAmountState();
}

class _enterAmountState extends State<enterAmount> {
  TextEditingController amountController=TextEditingController();

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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Amount",style: TextStyle(fontWeight: FontWeight.w400,
                      // color: _isNightMode?Colors.white: Colors.black,
                      color: colorConst.primaryColor3,
                      fontSize: MediaQuery.of(context).size.width*0.03),),
                ),
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
                      controller: amountController,
                      style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w400),
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('₹',style: TextStyle(
                              fontWeight: FontWeight.w600
                          ),),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.all(10),
                        hintText:"Enter Amount",
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
