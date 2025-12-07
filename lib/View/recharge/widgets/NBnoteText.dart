import 'package:flutter/cupertino.dart';

import '../../../main.dart';


/// constructor for the note text in the recharge screen
class NBNoteText extends StatelessWidget {
  const NBNoteText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: scrWidth*1,
      child: Padding(
        padding: const EdgeInsets.only(left: 14,right: 14),
        child: Text('Note: Please verify all information before doing transactions. After transaction our company will not responsible.',style: TextStyle(
          fontSize: scrWidth*0.029,
        ),textAlign: TextAlign.center,),
      ),
    );
  }
}
