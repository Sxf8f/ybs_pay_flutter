import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ybs_pay/View/recharge/selectProviderScreen.dart';
import 'package:ybs_pay/View/recharge/widgets/NBnoteText.dart';
import 'package:ybs_pay/View/recharge/widgets/appbarInRechargeScreen.dart';
import 'package:ybs_pay/View/recharge/widgets/enterAmountField.dart';
import 'package:ybs_pay/View/recharge/widgets/loading.dart';
import 'package:ybs_pay/View/recharge/widgets/prepaidNumberField.dart';
import 'package:ybs_pay/View/recharge/widgets/rechargeButton.dart';
import 'package:ybs_pay/View/recharge/widgets/selectProvider.dart';
import 'package:ybs_pay/View/recharge/widgets/tabButtons.dart';
import 'package:ybs_pay/View/recharge/widgets/viewPlanBestOfferButton.dart';

import '../../core/const/color_const.dart';
import '../../main.dart';


class rechargeScreen extends StatefulWidget {
  final rechargeProviderName;
  const rechargeScreen({super.key,required this.rechargeProviderName});
  @override
  State<rechargeScreen> createState() => _rechargeScreenState();
}

class _rechargeScreenState extends State<rechargeScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  void switchToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      currentIndex = index;
    });
  }
  Widget buildButton(String label, int index) {
    return ElevatedButton(
      onPressed: () => switchToPage(index),
      style: ElevatedButton.styleFrom(
        // backgroundColor: colorConst.primaryColor1,
        elevation:3,
        backgroundColor: currentIndex == index ? colorConst.primaryColor1 : Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.only(right: index==0?5:16,left: index==0?5:16),
        child: Text(label,style: TextStyle(
            fontSize: scrWidth*0.03,
            fontWeight: FontWeight.w500,
            color: currentIndex == index ?Colors.white:colorConst.primaryColor3
        ),),
      ),
    );
  }

  TextEditingController prepaidNumberController=TextEditingController();
  TextEditingController amountController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /// App bar in the recharge screen
      appBar: appBarInRechargeScreen(),
      body: Column(
        children: [

          /// Recharge and History tab buttons
          TabButtons(
            onTabSelected: (index) {
              setState(() {
                currentIndex = index;
              });},),
          Expanded(
            child: PageView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: [
                currentIndex==0?
                    /// Recharge screen part
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 40,),

                      /// prepaid number field
                      prepaidNumberField(prepaidNumberController: prepaidNumberController),
                      SizedBox(height: 20,),

                      /// recharge provider selection  button
                      selectProviderButton(rechargeProviderName: widget.rechargeProviderName),
                      SizedBox(height: 20,),

                      /// buttons for view plan, best offer and plan pdf
                      viewPlanBestOffer(),
                      SizedBox(height: 20,),

                      /// enter amount field
                      enterAmountField(amountController: amountController),
                      SizedBox(height: 20,),

                      /// NB note text
                      NBNoteText(),
                      SizedBox(height: 20,),

                      /// Recharge button
                      rechargeButton()
                  ],),
                ):



                    /// Recharge history screen part *


                /// loading gif
                loadingGif(),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
