import 'package:flutter/material.dart';
import 'package:ybs_pay/View/recharge/selectProviderScreen.dart';
import '../../../main.dart';



/// constructor for the select provider button
class selectProviderButton extends StatelessWidget {
  final rechargeProviderName;
  const selectProviderButton({super.key, required this.rechargeProviderName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => selectProvider(),));
      },
      child: Container(
        width: MediaQuery.of(context).size.width*0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scrWidth*0.02),
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 2,
                  offset: Offset(4, 4),
                  spreadRadius: 1
              )
            ]
        ),
        child: Padding(
          padding: const  EdgeInsets.only(
            left: 16,
            right: 20,
            top: 16,
            bottom: 16,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(Icons.cell_tower_outlined,color: Colors.grey.shade600,),
                        ),
                        Text(
                          rechargeProviderName!=null?
                          "${rechargeProviderName}":
                          "Select Provider",
                          style: TextStyle(fontWeight: FontWeight.w500,
                              color:  rechargeProviderName!=null?Colors.black:Colors.grey.shade400,
                              fontSize: MediaQuery.of(context).size.width*0.035),),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,color: Colors.grey,)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
