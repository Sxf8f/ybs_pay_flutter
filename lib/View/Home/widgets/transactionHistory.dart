import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ybs_pay/View/TransactionHistory/transaction_history.dart';

import '../../../core/const/color_const.dart';

class transactionHistory extends StatelessWidget {
  const transactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20,bottom: 16,left: 0,right: 0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TransactHistory(),));
        },
        child: Container(
          // height: MediaQuery.of(context).size.width*0.3,
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
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.015),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const  EdgeInsets.only(
                  left: 6,
                  right: 20,
                  top: 15,
                  bottom: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "Transaction History",
                            style: TextStyle(fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: MediaQuery.of(context).size.width*0.033),),
                        ),
                      ],
                    ),
                    Icon(Icons.history,color: Colors.black,),
        
                  ],
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }
}
