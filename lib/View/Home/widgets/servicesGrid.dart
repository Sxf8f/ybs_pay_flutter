import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../recharge/rechargeScreen.dart';


///Constructor for the services grid in the app

class servicesGrid extends StatefulWidget {
  const servicesGrid({super.key});

  @override
  State<servicesGrid> createState() => _servicesGridState();
}

class _servicesGridState extends State<servicesGrid> {
  bool loansMoreView=false;
  List services=[
    {
      'name':'Prepaid',
      'icon':Icons.phone_android_sharp
    },
    {
      'name':'PostPaid',
      'icon':Icons.phone_android
    },
    {
      'name':'DTH',
      'icon':Icons.tv
    },
    {
      'name':'Landline',
      'icon':Icons.house_outlined
    },

    {
      'name':'Electricity',
      // 'name':'Gastroenterology',
      'icon':Icons.electric_bolt_outlined
    },
    {
      'name':'Piped Gas',
      'icon':Icons.gas_meter_outlined
    },
    {
      'name':'Broadband',
      'icon':Icons.connected_tv
    },
    {
      'name':'Water',
      'icon':Icons.water_drop_outlined
    },

    {
      'name':'Loan Repayment',
      'icon':Icons.payments_outlined
    },
    {
      'name':'LPG',
      'icon':Icons.gas_meter_outlined
    },
    {
      'name':'Education Fees',
      'icon':Icons.school_sharp
    },
    {
      'name':'Housing Society',
      'icon':Icons.house_outlined
    },


    {
      'name':'Credit Card',
      'icon':Icons.credit_card_rounded
    },
    {
      'name':'Fund Request',
      'icon':Icons.money
    },
    {
      'name':'Call Back Request',
      'icon':Icons.phone_forwarded
    },
    {
      'name':'Whatsapp',
      'icon':Icons.phone
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.width*0.4,
      width: MediaQuery.of(context).size.width*1,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.01),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:  EdgeInsets.only(
                  left: MediaQuery.of(context).size.width*0.05,
                  top: MediaQuery.of(context).size.width*0.05,
                  bottom: MediaQuery.of(context).size.width*0.05,
                ),
                child: Text(
                  "Recharge, Pay Bills & Others",
                  style: TextStyle(fontWeight: FontWeight.w500,
                      color: colorConst.primaryColor1,
                      fontSize: MediaQuery.of(context).size.width*0.03),),
              ),
              Padding(
                padding:  EdgeInsets.only(
                  right: MediaQuery.of(context).size.width*0.05,
                  top: MediaQuery.of(context).size.width*0.05,
                  bottom: MediaQuery.of(context).size.width*0.05,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      loansMoreView=!loansMoreView;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        loansMoreView?
                        "View Less ":
                        "View More ",
                        style: TextStyle(fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width*0.025),),
                      Icon(
                        loansMoreView?
                        Icons.keyboard_arrow_up_rounded:
                        Icons.keyboard_arrow_down_outlined
                        ,color: Colors.grey,),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: loansMoreView?services.length:8,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 2
              ),
              itemBuilder:   (context, index) {
                final service=services[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => rechargeScreen(rechargeProviderName: null,),));
                  },
                  child: Container(
                    // height: MediaQuery.of(context).size.width*0.3,
                    width: MediaQuery.of(context).size.width*0.22,
                    // color: Colors.yellow,
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width*0.16,
                          width: MediaQuery.of(context).size.width*0.16,
                          decoration: BoxDecoration(
                            // image: DecorationImage(image: AssetImage(categ['image'])),
                            color: colorConst.lightBlue,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.5),
                          ),
                          child: Icon(service['icon'],color: Colors.black,),
                        ),
                        Padding(
                          padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width*0.03),
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            height: MediaQuery.of(context).size.width*0.1,
                            child: Text( service['name'],
                              style: TextStyle(fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.width*0.029),
                              // overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },),
          )
        ],
      ),
    );
  }
}
