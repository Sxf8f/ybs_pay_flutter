import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';


/// Constructor for the wallet type and balance
class walletType extends StatelessWidget {
  const walletType({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0,left: 8),
      child: Container(
        width: MediaQuery.of(context).size.width*0.88,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Wallet Type",style: TextStyle(fontWeight: FontWeight.w400,
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Text('Prepaid Wallet',style: TextStyle(
                            fontSize: scrWidth*0.03,
                          ),),

                          Text('₹ 244.23',style: TextStyle(
                              fontSize: scrWidth*0.03
                          ),)
                        ],
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
