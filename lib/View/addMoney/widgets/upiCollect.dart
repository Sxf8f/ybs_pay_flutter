import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

/// Constructor for the upi collect button
class upiCollectButton extends StatelessWidget {
  const upiCollectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => GlossSwipe(),));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(scrWidth * 0.045),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 2,
              offset: Offset(4, 4),
              spreadRadius: 1,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 20, top: 14, bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "UPI Collect",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.042,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4,),
                      Text(
                        "Charges : 0 %",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colorConst.primaryColor3,
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Min : 1.0 ₹ - Max : 2000.0 ₹",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage('assets/images/ybs.jpeg'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(scrWidth * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 2,
                          offset: Offset(4, 4),
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
