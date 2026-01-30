import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ybs_pay/View/scanQr/widgets/flashIcon.dart';
import 'package:ybs_pay/View/scanQr/widgets/myQrIcon.dart';
import 'package:ybs_pay/View/scanQr/widgets/qrCodeScanner.dart';
import 'package:ybs_pay/View/scanQr/widgets/scannerBorder.dart';
import 'package:ybs_pay/core/bloc/walletBloc/walletBloc.dart';
import 'package:ybs_pay/core/bloc/walletBloc/walletEvent.dart';
import 'package:ybs_pay/core/repository/walletRepository/walletRepo.dart';
import 'package:ybs_pay/View/enterUpiAmount/enterAmountScreen.dart';
import 'package:ybs_pay/main.dart';

class scanQrScreen extends StatefulWidget {
  const scanQrScreen({super.key});

  @override
  State<scanQrScreen> createState() => _scanQrScreenState();
}

class _scanQrScreenState extends State<scanQrScreen> {
  MobileScannerController? _cameraController;
  double _zoomLevel = 0.0;

  @override
  void initState() {
    super.initState();
    print('📱 [SCAN_QR] Initializing scanQrScreen...');
    _cameraController = MobileScannerController();
    print('📱 [SCAN_QR] MobileScannerController created');
    print('📱 [SCAN_QR] Zoom level initialized: $_zoomLevel');
    print('✅ [SCAN_QR] scanQrScreen initialization complete');
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      print('🖼️ [SCAN_QR] Opening gallery picker...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      print(
        '🖼️ [SCAN_QR] Image picked: ${image != null ? image.path : "null"}',
      );

      if (image != null) {
        print('🖼️ [SCAN_QR] Image path: ${image.path}');
        print('🖼️ [SCAN_QR] Image name: ${image.name}');
        print('🖼️ [SCAN_QR] Image size: ${await image.length()} bytes');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing QR code from image...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Decode QR from gallery image using MobileScanner
        print('🔍 [SCAN_QR] Analyzing image for QR codes...');
        final file = File(image.path);
        if (!await file.exists()) {
          print('❌ [SCAN_QR] Image file does not exist');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Image file not found'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        try {
          final result = await _cameraController?.analyzeImage(image.path);
          print('🔍 [SCAN_QR] Analysis result: $result');

          if (result != null && result.barcodes.isNotEmpty) {
            final barcode = result.barcodes.first;
            final qrValue = barcode.rawValue;
            print('✅ [SCAN_QR] QR code found: $qrValue');

            if (qrValue != null) {
              // Process QR code same way as camera scanner
              if (qrValue.startsWith('YBS_PAY|')) {
                print('✅ [SCAN_QR] YBS_PAY QR detected, validating...');
                if (!context.mounted) {
                  print(
                    '❌ [SCAN_QR] Context not mounted, cannot access WalletBloc',
                  );
                  return;
                }
                context.read<WalletBloc>().add(
                  ValidateQRRequested(qrData: qrValue),
                );
                print('✅ [SCAN_QR] ValidateQRRequested event dispatched');
              } else if (qrValue.startsWith('upi://')) {
                print(
                  '✅ [SCAN_QR] UPI QR detected, navigating to amount screen...',
                );
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => enterAmountScreen(upiId: qrValue),
                  ),
                );
              } else {
                print('⚠️ [SCAN_QR] Unknown QR format: $qrValue');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('QR code format not supported: $qrValue'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } else {
            print('⚠️ [SCAN_QR] No QR code found in image');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No QR code found in the selected image'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          print('❌ [SCAN_QR] Error analyzing image: $e');
          print('❌ [SCAN_QR] Error stack trace: ${StackTrace.current}');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error decoding QR code: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('⚠️ [SCAN_QR] No image selected from gallery');
      }
    } catch (e) {
      print('❌ [SCAN_QR] Error picking image: $e');
      print('❌ [SCAN_QR] Error stack trace: ${StackTrace.current}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletBloc(walletRepository: WalletRepository()),
      child: Scaffold(
        body: Stack(
          children: [
            /// Qr code scanner
            qrCodeScanner(),

            /// Qr border
            qrBorder(),

            /// 'Scan qr to pay' text
            Positioned(
              top: 50,
              child: SizedBox(
                width: scrWidth * 1,
                child: Center(
                  child: Text(
                    'Scan QR to pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scrWidth * 0.05,
                    ),
                  ),
                ),
              ),
            ),

            /// My QR Code icon
            myQrIcon(),

            /// flash enable icon
            flashIcon(),

            /// Zoom Control (Bottom left)
            // Positioned(
            //   bottom: 100,
            //   left: 20,
            //   child: Column(
            //     children: [
            //       Container(
            //         width: 50,
            //         height: 80,
            //         decoration: BoxDecoration(
            //           color: Colors.black.withOpacity(0.6),
            //           borderRadius: BorderRadius.circular(25),
            //         ),
            //         child: RotatedBox(
            //           quarterTurns: 3,
            //           child: Slider(
            //             value: _zoomLevel,
            //             min: 0.0,
            //             max: 1.0,
            //             onChanged: (value) {
            //               print(
            //                 '🔍 [SCAN_QR] Zoom slider changed: $value (${(value * 100).toStringAsFixed(0)}%)',
            //               );
            //               setState(() {
            //                 _zoomLevel = value;
            //               });
            //               print(
            //                 '🔍 [SCAN_QR] Setting zoom scale to: $_zoomLevel',
            //               );
            //               _cameraController
            //                   ?.setZoomScale(_zoomLevel)
            //                   .then((_) {
            //                     print(
            //                       '✅ [SCAN_QR] Zoom scale successfully set to: $_zoomLevel',
            //                     );
            //                   })
            //                   .catchError((e) {
            //                     print(
            //                       '❌ [SCAN_QR] Error setting zoom scale: $e',
            //                     );
            //                   });
            //             },
            //             activeColor: Colors.white,
            //             inactiveColor: Colors.grey,
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 8),
            //       Icon(Icons.zoom_in, color: Colors.white, size: 20),
            //     ],
            //   ),
            // ),

            /// Gallery Button (Bottom right)
            Positioned(
              bottom: 100,
              right: 20,
              child: Builder(
                builder: (builderContext) => Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.image, color: Colors.white, size: 24),
                    onPressed: () => _pickImageFromGallery(builderContext),
                    tooltip: 'Pick from Gallery',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
