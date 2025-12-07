import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybs_pay/core/const/color_const.dart';

import '../../../main.dart';

class notificationBox extends StatelessWidget {
  const notificationBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(scrWidth*0.024),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 2,
                offset: Offset(3, 3),
                spreadRadius: 1

            )
          ]
      ),
      child: Padding(
        padding: const  EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    height: 30,
                    width: 30,
                    child: SvgPicture.asset('assets/svg/notification_ybs.svg',color: colorConst.primaryColor1,)),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Recharge Failed",
                        style: TextStyle(fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width*0.035),),

                      Padding(
                        padding: const EdgeInsets.only(top: 2,bottom: 8),
                        child: Text(
                          "No Templates Found",
                          style: TextStyle(fontWeight: FontWeight.w500,
                              fontSize: MediaQuery.of(context).size.width*0.025),),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.calendar_month,color: Colors.grey.shade300,size: 18,),
                          ),
                          Text(
                            "19 Jun 2025 9:30:18 PM",
                            style: TextStyle(fontWeight: FontWeight.w500,
                                fontSize: MediaQuery.of(context).size.width*0.025),),
                        ],
                      ),
                    ],
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
