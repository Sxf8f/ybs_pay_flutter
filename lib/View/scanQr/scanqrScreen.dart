import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ybs_pay/View/scanQr/widgets/cornerBorderPainter.dart';
import 'package:ybs_pay/View/scanQr/widgets/flashIcon.dart';
import 'package:ybs_pay/View/scanQr/widgets/flipcamera.dart';
import 'package:ybs_pay/View/scanQr/widgets/qrCodeScanner.dart';
import 'package:ybs_pay/View/scanQr/widgets/scannerBorder.dart';
import 'package:ybs_pay/main.dart';



class scanQrScreen extends StatelessWidget {
  const scanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Qr code scanner
          qrCodeScanner(),

          /// Qr border
          qrBorder(),

          /// 'Scan qr to pay' text
          Positioned(
            top: 50,
            // c: 20,
            child: SizedBox(
              width: scrWidth*1,
              child: Center(
                child: Text(
                  'Scan QR to pay'
                  ,style: TextStyle(
                  color: Colors.white,
                  fontSize: scrWidth*0.05
                ),),
              ),
            ),
          ),

          /// flip camera icon
          flipCamera(),

          /// flash enable icon
          flashIcon(),

        ],
      ),

    );
  }
}
