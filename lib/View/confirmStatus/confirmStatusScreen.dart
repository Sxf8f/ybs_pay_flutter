import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:ybs_pay/View/Home/1homeScreen.dart';
import 'package:ybs_pay/View/confirmStatus/widgets/doneButton.dart';
import 'package:ybs_pay/View/confirmStatus/widgets/sendAmount.dart';
import 'package:ybs_pay/View/confirmStatus/widgets/successGif.dart';
import 'package:ybs_pay/View/confirmStatus/widgets/successfulText.dart';
import 'package:ybs_pay/navigationPage.dart';

import '../../../main.dart';
import '../../core/const/color_const.dart';
import '../../core/const/assets_const.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appState.dart';

class confirmStatus extends StatefulWidget {
  final amount;
  const confirmStatus({super.key, required this.amount});

  @override
  State<confirmStatus> createState() => _confirmStatusState();
}

class _confirmStatusState extends State<confirmStatus> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSuccessSound();
  }

  Future<void> _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('sounds/success-340660.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: scrWidth * 1.35,
          width: scrWidth * 0.88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Logo from AppBloc
              BlocBuilder<AppBloc, AppState>(
                buildWhen: (previous, current) => current is AppLoaded,
                builder: (context, state) {
                  String? logoPath;
                  if (state is AppLoaded && state.settings?.logo != null) {
                    logoPath =
                        "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                  }
                  return Container(
                    height: scrWidth * 0.11,
                    child: logoPath != null && logoPath.isNotEmpty
                        ? Image.network(
                            logoPath,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox.shrink();
                            },
                          )
                        : SizedBox.shrink(),
                  );
                },
              ),

              /// success gif
              successStatusGif(),

              /// amount text in the success screen
              sendAmountText(amount: widget.amount),

              /// successful text
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0,top: 8.0),
                child: successfulText(),
              ),

              /// Done button with navigation to home screen
              doneButtonInConfirmStatus(),
            ],
          ),
        ),
      ),
    );
  }
}
