import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/const/color_const.dart';

class progressiveDotsLoading extends StatelessWidget {
  const progressiveDotsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: MediaQuery.of(context).size.width*0.2,
        height: 45,
        child: LoadingAnimationWidget.progressiveDots(
          size: 50,
          color: colorConst.primaryColor1,
        ),
      ),
    );
  }
}
