import 'package:flutter/material.dart';
import 'package:ybs_pay/View/enterUpiAmount/widgets/amountField.dart';
import 'package:ybs_pay/View/enterUpiAmount/widgets/appBarInTheEnterAmount.dart';
import 'package:ybs_pay/View/enterUpiAmount/widgets/upiId.dart';
import 'package:ybs_pay/View/enterUpiAmount/widgets/upiPayeeName.dart';
import 'package:ybs_pay/View/enterUpiAmount/widgets/upiUserProfile.dart';
import 'package:ybs_pay/main.dart';

import '../../test/test1.dart';
import '../confirmStatus/confirmStatusScreen.dart';

class enterAmountScreen extends StatefulWidget {
  final upiId;
  const enterAmountScreen({super.key, required this.upiId});

  @override
  State<enterAmountScreen> createState() => _enterAmountScreenState();
}

class _enterAmountScreenState extends State<enterAmountScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarInEnterAmountScreen(),
      backgroundColor: Colors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50,),

              /// upi user profile picture
              upiProfilePicture(),
              SizedBox(height: 20,),

              /// upi user payee name
              upiPayeeName(upiId: widget.upiId),
              SizedBox(height: 20,),


              /// Amount field
              // AmountField(),
              amountField(),
              SizedBox(height: 40,),

              /// upi id
              upiId(upiUserId: widget.upiId),



            ],
          ),
        ],
      ),
    );
  }
}




