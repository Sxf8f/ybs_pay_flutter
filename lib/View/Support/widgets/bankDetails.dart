import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';


/// A container button for bank details

class bankDetailsBox extends StatelessWidget {
  const bankDetailsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.grey.shade300,
      // height: MediaQuery.of(context).size.width*0.14,
      width: MediaQuery.of(context).size.width*0.92,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(scrWidth*0.015),
          color: Colors.white,
          // border: Border.all(
          //   color: Colors.grey.shade300,
          // ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 2,
                // blurStyle: BlurStyle.outer,
                offset: Offset(0, 0),
                spreadRadius: 1

            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16,right: 16,top: 12,bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                        height: 30,
                        width: 30,
                        child: Icon(Icons.account_balance)),
                    Padding(
                      padding: EdgeInsets.only(left: scrWidth*0.07),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bank Details',style: TextStyle(
                              fontWeight: FontWeight.w500,fontSize: scrWidth*0.033),),
                        ],
                      ),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_right)



              ],
            ),
          ],
        ),
      ),
    );
  }
}
