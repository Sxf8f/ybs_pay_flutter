import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';


/// A facebook container with facebook icon and face book launching follow us button
class facebookBox extends StatelessWidget {
  const facebookBox({super.key});

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
        padding: const EdgeInsets.only(left: 16,right: 16,top: 20,bottom: 20),
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                        height: 30,
                        width: 30,
                        child: SvgPicture.asset('assets/svg/facebook.svg')),
                    Padding(
                      padding: EdgeInsets.only(left: scrWidth*0.07),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Facebook',style: TextStyle(
                              fontWeight: FontWeight.w500,fontSize: scrWidth*0.033),),
                          Text('Follow Us',style: TextStyle(
                              fontWeight: FontWeight.w500,fontSize: scrWidth*0.028,
                              color: colorConst.primaryColor1,
                              decoration: TextDecoration.underline,
                              decorationColor: colorConst.primaryColor1
                          ),),
                        ],
                      ),
                    ),
                  ],
                ),



              ],
            ),
          ],
        ),
      ),
    );
  }
}
