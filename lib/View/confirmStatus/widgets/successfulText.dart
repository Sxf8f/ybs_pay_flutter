import 'package:flutter/cupertino.dart';

import '../../../main.dart';


/// successful text in the confirm status screen
class successfulText extends StatelessWidget {
  const successfulText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Transaction successful.",style: TextStyle(fontWeight: FontWeight.w500,
        fontSize: scrWidth*0.034),);
  }
}
