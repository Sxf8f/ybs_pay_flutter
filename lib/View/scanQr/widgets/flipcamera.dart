import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


/// flip camera in the qr scanner screen
class flipCamera extends StatefulWidget {
  const flipCamera({super.key});

  @override
  State<flipCamera> createState() => _flipCameraState();
}

class _flipCameraState extends State<flipCamera> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: IconButton(
        icon: Icon(Icons.flip_camera_android, color: Colors.white),
        onPressed: () => cameraController.switchCamera(),
      ),
    );
  }
}
