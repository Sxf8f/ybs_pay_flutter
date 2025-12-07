import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';



/// Constructor for accounts and finance contact details in a container
class accountsFinanceBox extends StatefulWidget {
  const accountsFinanceBox({super.key});

  @override
  State<accountsFinanceBox> createState() => _accountsFinanceBoxState();
}

class _accountsFinanceBoxState extends State<accountsFinanceBox> {
  bool accountsDrop=false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              accountsDrop=!accountsDrop;
            });
          },
          child: Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              height: 30,
                              width: 30,
                              child: SvgPicture.asset('assets/svg/cardHolder.svg')),
                          Padding(
                            padding: EdgeInsets.only(left: scrWidth*0.07),
                            child: Text('Accounts & Finance',style: TextStyle(
                                fontWeight: FontWeight.w500,fontSize: scrWidth*0.033),),
                          ),
                        ],
                      ),
                      Icon(accountsDrop?Icons.keyboard_arrow_up_rounded:Icons.keyboard_arrow_down_rounded)



                    ],
                  ),
                  accountsDrop?
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('9037187402',style: TextStyle(
                                color: colorConst.primaryColor3,
                                fontSize: scrWidth*0.035,
                                fontWeight: FontWeight.w600
                            ),),
                            Icon(Icons.phone_android,color: Colors.grey.shade400,)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('9037187402',style: TextStyle(
                                color: colorConst.primaryColor3,
                                fontSize: scrWidth*0.035,
                                fontWeight: FontWeight.w600
                            ),),
                            Icon(Icons.phone,color: Colors.grey.shade400,)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('9037187402',style: TextStyle(
                                color: colorConst.primaryColor3,
                                fontSize: scrWidth*0.035,
                                fontWeight: FontWeight.w600
                            ),),
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset('assets/svg/whatsapp.svg'),
                            )
                            // Icon(Icons.phone,color: Colors.grey.shade400,)
                          ],
                        ),
                      ),
                    ],
                  ):
                  SizedBox()
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
