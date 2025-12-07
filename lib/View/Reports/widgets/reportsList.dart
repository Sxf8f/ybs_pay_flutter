import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

/// Constructor for the reports list in the app
class reportsList extends StatefulWidget {
  const reportsList({super.key});

  @override
  State<reportsList> createState() => _reportsListState();
}

class _reportsListState extends State<reportsList> {
  List services=[
    {
      'name':'Recharge Report',
      'icon':Icons.phone_android_outlined
    },
    {
      'name':'Specific Recharge Report',
      'icon':Icons.phone_android
    },
    {
      'name':'Ledger Report',
      'icon':Icons.notes
    },
    {
      'name':'Fund Order Report',
      'icon':Icons.note_alt_outlined
    },

    {
      'name':'Complaint Report',
      // 'name':'Gastroenterology',
      'icon':Icons.warning_amber_outlined
    },
    {
      'name':'Fund Debit Credit',
      'icon':Icons.credit_card_rounded
    },
    {
      'name':'User Daybook',
      'icon':Icons.calendar_view_day
    },
    {
      'name':'Commission Slab',
      'icon':Icons.percent
    },


    {
      'name':'W2R Report',
      'icon':Icons.report_gmailerrorred
    },
    {
      'name':'Daybook DMT',
      'icon':Icons.calendar_month
    },

  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final report =services[index];
            return Padding(
              padding: const EdgeInsets.only(top: 8,bottom: 0),
              child: Container(
                // color: Colors.grey.shade300,
                // height: MediaQuery.of(context).size.width*0.14,
                width: MediaQuery.of(context).size.width*1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(scrWidth*0.015),
                  color: Colors.white,
                  // border: Border.all(
                  //   color: Colors.grey.shade300,
                  // ),
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.grey.shade300,
                  //       blurRadius: 2,
                  //       // blurStyle: BlurStyle.outer,
                  //       offset: Offset(4, 4),
                  //       spreadRadius: 1
                  //
                  //   )
                  // ]
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16,left: 16,bottom: 8,top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            // maxRadius: scrWidth*0.1,
                            minRadius: scrWidth*0.065,
                            child: Icon(report['icon'],color: Colors.black,),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: scrWidth*0.07),
                            child: Text(report['name'],style: TextStyle(
                                fontWeight: FontWeight.w500,fontSize: scrWidth*0.033),),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,size: 20,),


                    ],
                  ),
                ),
              ),
            );
          },),
        SizedBox(height: 25,)
      ],
    );
  }
}
