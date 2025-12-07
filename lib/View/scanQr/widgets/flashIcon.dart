import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';



/// flash icon qr scanner camera screen
class flashIcon extends StatefulWidget {
  const flashIcon({super.key});

  @override
  State<flashIcon> createState() => _flashIconState();
}

class _flashIconState extends State<flashIcon> {
  MobileScannerController cameraController = MobileScannerController();
  bool isTorchOn = false;


  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: IconButton(
        icon: Icon(
          isTorchOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () async {
          await cameraController.toggleTorch();
          setState(() {
            isTorchOn = !isTorchOn;
          });
        },
      ),
    );
  }
}
