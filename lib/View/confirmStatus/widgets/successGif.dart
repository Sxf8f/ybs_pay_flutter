import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:ybs_pay/core/const/assets_const.dart';

/// constructor for the success
class successStatusGif extends StatelessWidget {
  const successStatusGif({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(AssetsConst.successLottie);
  }
}
