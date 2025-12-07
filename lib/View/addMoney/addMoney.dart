import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ybs_pay/View/addMoney/widgets/amount.dart';
import 'package:ybs_pay/View/addMoney/widgets/appbarAddMoney.dart';
import 'package:ybs_pay/View/addMoney/widgets/upiCollect.dart';
import 'package:ybs_pay/View/addMoney/widgets/walletType.dart';

import '../../core/const/color_const.dart';
import '../../main.dart';


class addMoneyScreen extends StatefulWidget {
  const addMoneyScreen({super.key});

  @override
  State<addMoneyScreen> createState() => _addMoneyScreenState();
}

class _addMoneyScreenState extends State<addMoneyScreen>  {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarAddMoney(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    /// Wallet type and balance
                    walletType(),


                    /// Enter amount
                    enterAmount(),
                    SizedBox(height: 40,),

                    /// UPI collect button
                    upiCollectButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
