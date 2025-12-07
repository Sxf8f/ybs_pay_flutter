import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../enterUpiAmount/enterAmountScreen.dart';

class qrCodeScanner extends StatefulWidget {
  const qrCodeScanner({super.key});

  @override
  State<qrCodeScanner> createState() => _qrCodeScannerState();
}

/// upi qr scanner
class _qrCodeScannerState extends State<qrCodeScanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanned = false;
  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: cameraController,
      onDetect: (capture) {
        if (_scanned) return;
        final barcode = capture.barcodes.first;
        final value = barcode.rawValue;
        if (value != null && value.startsWith('upi://')) {
          _scanned = true;
          cameraController.stop();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => enterAmountScreen(upiId: value),),);
        }
      },
    );
  }
}
