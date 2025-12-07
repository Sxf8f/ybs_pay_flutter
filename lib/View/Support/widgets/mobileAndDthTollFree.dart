import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';



/// Mobile and dth toll free container with alert dialogue with contact number

class mobileAndDthTollFreeBox extends StatefulWidget {
  const mobileAndDthTollFreeBox({super.key});

  @override
  State<mobileAndDthTollFreeBox> createState() => _mobileAndDthTollFreeBoxState();
}

class _mobileAndDthTollFreeBoxState extends State<mobileAndDthTollFreeBox> {

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch phone dialer');
    }
  }
  showTollFreeDialogue(bool isMobileToll){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10,left: 7),
                child: Text(
                  isMobileToll?
                  "Prepaid Support":
                  "DTH Support"
                  ,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: scrWidth*0.035,
                      fontWeight: FontWeight.w600,
                      color: colorConst.primaryColor3
                  ),),
              ),

            ],
          ),
          content: SizedBox(
            height: scrWidth*0.38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 18,),
                Text(
                  isMobileToll?
                  'BSNL- Special Tariff':
                  'Dish Tv'
                  ,style: TextStyle(
                    fontSize: scrWidth*0.04,
                    fontWeight: FontWeight.w600
                ),),
                SizedBox(height: 10,),
                InkWell(
                  onTap: () {
                    _launchPhone(
                        isMobileToll?
                        '1503':
                        '1800-2700-300'
                    );
                  },
                  child: Text('1800-2700-300',style: TextStyle(
                      fontSize: scrWidth*0.035,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline
                  ),),
                ),
                // SizedBox(height: 10,),

                SizedBox(height: 10,),




                Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox.shrink(),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Text("Done",
                          style: TextStyle(
                            // color: colorConst.primaryColor3,
                              fontSize: scrWidth*0.03,
                              fontWeight: FontWeight.w300
                          ),),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Mobile Toll Free
        InkWell(
          onTap: () {
            showTollFreeDialogue(true);
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
                              child: Icon(Icons.phone_android)),
                          Padding(
                            padding: EdgeInsets.only(left: scrWidth*0.07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mobile Toll Free',style: TextStyle(
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
          ),
        ),


        SizedBox(height: scrWidth*0.04,),

        /// DTH TOll free
        InkWell(
          onTap: () {
            showTollFreeDialogue(false);
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
                              child: Icon(Icons.tv_outlined)),
                          Padding(
                            padding: EdgeInsets.only(left: scrWidth*0.07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DTH Toll Free',style: TextStyle(
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
          ),
        ),
      ],
    );
  }
}
