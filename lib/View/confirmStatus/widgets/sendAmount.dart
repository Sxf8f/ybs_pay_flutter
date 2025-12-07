import 'package:flutter/cupertino.dart';

import '../../../main.dart';


/// send amount text in the confirm status  screen
class sendAmountText extends StatelessWidget {
  final amount;
  const sendAmountText({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("₹ ${amount}",style: TextStyle(fontWeight: FontWeight.w500,
            fontSize: scrWidth*0.05),),
      ],
    );
  }
}
