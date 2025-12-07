import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../../../main.dart';


/// constructor for the loading gif
class loadingGif extends StatelessWidget {
  const loadingGif({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 60,),
          SizedBox(
              width: scrWidth*0.7,
              child: Lottie.asset('assets/gifs/noBillAnimation.json')),
          SizedBox(height: 20,),
          Text('No recent bill pay yet.',style: TextStyle(
              fontSize: scrWidth*0.033
          ),),

          SizedBox(height: 20,),
        ],),
    );
  }
}
