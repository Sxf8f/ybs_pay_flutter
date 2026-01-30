import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/bloc/distributorBloc/distributorScanPayBloc.dart';
import '../../../core/bloc/distributorBloc/distributorScanPayEvent.dart';
import '../../../core/bloc/distributorBloc/distributorScanPayState.dart';
import '../../../core/repository/distributorRepository/distributorRepo.dart';
import '../../../core/models/distributorModels/distributorScanPayModel.dart';
import '../../../main.dart';
import '../../../core/const/color_const.dart';
import '../../widgets/app_bar.dart';
import '../../enterUpiAmount/enterAmountScreen.dart';

class DistributorScanPayScreen extends StatefulWidget {
  const DistributorScanPayScreen({super.key});

  @override
  State<DistributorScanPayScreen> createState() =>
      _DistributorScanPayScreenState();
}

class _DistributorScanPayScreenState extends State<DistributorScanPayScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanned = false;
  double _zoomLevel = 0.0;

  @override
  void initState() {
    super.initState();
    print('📱 [DISTRIBUTOR_SCAN] Initializing DistributorScanPayScreen...');
    print('📱 [DISTRIBUTOR_SCAN] MobileScannerController created');
    print('📱 [DISTRIBUTOR_SCAN] Zoom level initialized: $_zoomLevel');
    print(
      '✅ [DISTRIBUTOR_SCAN] DistributorScanPayScreen initialization complete',
    );
  }

  @override
  void dispose() {
    print('🔌 [DISTRIBUTOR_SCAN] Disposing DistributorScanPayScreen...');
    cameraController.dispose();
    print('🔌 [DISTRIBUTOR_SCAN] Dispose complete');
    super.dispose();
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      print('🖼️ [DISTRIBUTOR_SCAN] Opening gallery picker...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      print(
        '🖼️ [DISTRIBUTOR_SCAN] Image picked: ${image != null ? image.path : "null"}',
      );

      if (image != null) {
        print('🖼️ [DISTRIBUTOR_SCAN] Image path: ${image.path}');
        print('🖼️ [DISTRIBUTOR_SCAN] Image name: ${image.name}');
        print(
          '🖼️ [DISTRIBUTOR_SCAN] Image size: ${await image.length()} bytes',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing QR code from image...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Decode QR from gallery image using MobileScanner
        print('🔍 [DISTRIBUTOR_SCAN] Analyzing image for QR codes...');
        final file = File(image.path);
        if (!await file.exists()) {
          print('❌ [DISTRIBUTOR_SCAN] Image file does not exist');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Image file not found'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        try {
          final result = await cameraController.analyzeImage(image.path);
          print('🔍 [DISTRIBUTOR_SCAN] Analysis result: $result');

          if (result != null && result.barcodes.isNotEmpty) {
            final barcode = result.barcodes.first;
            final qrValue = barcode.rawValue;
            print('✅ [DISTRIBUTOR_SCAN] QR code found: $qrValue');

            if (qrValue != null) {
              // Process QR code same way as camera scanner
              if (qrValue.startsWith('YBS_PAY|')) {
                print(
                  '✅ [DISTRIBUTOR_SCAN] YBS_PAY QR detected, validating...',
                );
                if (!context.mounted) {
                  print(
                    '❌ [DISTRIBUTOR_SCAN] Context not mounted, cannot access DistributorScanPayBloc',
                  );
                  return;
                }
                context.read<DistributorScanPayBloc>().add(
                  ValidateQREvent(qrData: qrValue),
                );
                print('✅ [DISTRIBUTOR_SCAN] ValidateQREvent dispatched');
              } else if (qrValue.startsWith('upi://')) {
                print(
                  '✅ [DISTRIBUTOR_SCAN] UPI QR detected, navigating to amount screen...',
                );
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => enterAmountScreen(upiId: qrValue),
                  ),
                );
              } else {
                print('⚠️ [DISTRIBUTOR_SCAN] Unknown QR format: $qrValue');
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
            print('⚠️ [DISTRIBUTOR_SCAN] No QR code found in image');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No QR code found in the selected image'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          print('❌ [DISTRIBUTOR_SCAN] Error analyzing image: $e');
          print(
            '❌ [DISTRIBUTOR_SCAN] Error stack trace: ${StackTrace.current}',
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error decoding QR code: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('⚠️ [DISTRIBUTOR_SCAN] No image selected from gallery');
      }
    } catch (e) {
      print('❌ [DISTRIBUTOR_SCAN] Error picking image: $e');
      print('❌ [DISTRIBUTOR_SCAN] Error stack trace: ${StackTrace.current}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DistributorScanPayBloc(DistributorRepository()),
      child: Scaffold(
        appBar: appBar(),
        body: BlocListener<DistributorScanPayBloc, DistributorScanPayState>(
          listener: (context, state) {
            if (state is DistributorScanPayQRValidated) {
              if (state.validation.valid &&
                  state.validation.recipient != null) {
                // Navigate to transfer screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DistributorQRTransferScreen(
                      recipient: state.validation.recipient!,
                      qrData: state.qrData,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.validation.message ?? 'Invalid QR code',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() {
                  _scanned = false;
                });
              }
            } else if (state is DistributorScanPayError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                _scanned = false;
              });
            }
          },
          child: Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  if (_scanned) return;
                  final barcode = capture.barcodes.first;
                  final value = barcode.rawValue;

                  if (value != null) {
                    // Check if it's YBS_PAY QR code
                    if (value.startsWith('YBS_PAY|')) {
                      setState(() {
                        _scanned = true;
                      });
                      cameraController.stop();
                      context.read<DistributorScanPayBloc>().add(
                        ValidateQREvent(qrData: value),
                      );
                    }
                    // Check if it's UPI QR code
                    else if (value.startsWith('upi://')) {
                      setState(() {
                        _scanned = true;
                      });
                      cameraController.stop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => enterAmountScreen(upiId: value),
                        ),
                      );
                    }
                  }
                },
              ),
              // Scanner border overlay
              Positioned.fill(
                child: CustomPaint(painter: ScannerBorderPainter()),
              ),
              // Title
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
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// Zoom Control (Bottom left)
              // Positioned(
              //   bottom: 30,
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
              //                 '🔍 [DISTRIBUTOR_SCAN] Zoom slider changed: $value (${(value * 100).toStringAsFixed(0)}%)',
              //               );
              //               setState(() {
              //                 _zoomLevel = value;
              //               });
              //               print(
              //                 '🔍 [DISTRIBUTOR_SCAN] Setting zoom scale to: $_zoomLevel',
              //               );
              //               cameraController
              //                   .setZoomScale(_zoomLevel)
              //                   .then((_) {
              //                     print(
              //                       '✅ [DISTRIBUTOR_SCAN] Zoom scale successfully set to: $_zoomLevel',
              //                     );
              //                   })
              //                   .catchError((e) {
              //                     print(
              //                       '❌ [DISTRIBUTOR_SCAN] Error setting zoom scale: $e',
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
                bottom: 30,
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
      ),
    );
  }
}

class ScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final width = size.width * 0.7;
    final height = width;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2;

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        Radius.circular(20),
      ),
      paint,
    );

    // Draw corners
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Top-left
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + width, top),
      Offset(left + width - cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + width, top),
      Offset(left + width, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + height),
      Offset(left + cornerLength, top + height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + height),
      Offset(left, top + height - cornerLength),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + width, top + height),
      Offset(left + width - cornerLength, top + height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + width, top + height),
      Offset(left + width, top + height - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Transfer Screen for Distributor QR Transfer
class DistributorQRTransferScreen extends StatefulWidget {
  final QRRecipient recipient;
  final String qrData;

  const DistributorQRTransferScreen({
    super.key,
    required this.recipient,
    required this.qrData,
  });

  @override
  State<DistributorQRTransferScreen> createState() =>
      _DistributorQRTransferScreenState();
}

class _DistributorQRTransferScreenState
    extends State<DistributorQRTransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _secureKeyController = TextEditingController();
  bool _showSecureKeyField = false;

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _secureKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DistributorScanPayBloc(DistributorRepository()),
      child: Scaffold(
        appBar: appBar(),
        body: BlocListener<DistributorScanPayBloc, DistributorScanPayState>(
          listener: (context, state) {
            if (state is DistributorScanPayTransferSuccess) {
              _showSuccessDialog(context, state.response);
            } else if (state is DistributorScanPayError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is DistributorScanPayRequiresSecureKey) {
              setState(() {
                _showSecureKeyField = true;
              });
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(scrWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Money',
                  style: TextStyle(
                    fontSize: scrWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: scrWidth * 0.04),
                // Recipient Info
                Container(
                  padding: EdgeInsets.all(scrWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorConst.primaryColor1,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recipient.name ??
                                  widget.recipient.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: scrWidth * 0.035,
                              ),
                            ),
                            if (widget.recipient.phone != null)
                              Text(
                                widget.recipient.phone!,
                                style: TextStyle(
                                  fontSize: scrWidth * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scrWidth * 0.04),
                // Amount
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: scrWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: scrWidth * 0.02),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: scrWidth * 0.03),
                // Remarks
                Text(
                  'Remarks (Optional)',
                  style: TextStyle(
                    fontSize: scrWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: scrWidth * 0.02),
                TextField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_showSecureKeyField) ...[
                  SizedBox(height: scrWidth * 0.03),
                  Text(
                    'Secure Key',
                    style: TextStyle(
                      fontSize: scrWidth * 0.035,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.02),
                  TextField(
                    controller: _secureKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter secure key',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: scrWidth * 0.04),
                // Transfer Button
                BlocBuilder<DistributorScanPayBloc, DistributorScanPayState>(
                  builder: (context, state) {
                    final isLoading =
                        state is DistributorScanPayTransferLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_amountController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please enter amount'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                context.read<DistributorScanPayBloc>().add(
                                  TransferViaQREvent(
                                    recipientUserId: widget.recipient.id,
                                    amount: _amountController.text,
                                    qrData: widget.qrData,
                                    remarks: _remarksController.text.isEmpty
                                        ? null
                                        : _remarksController.text,
                                    secureKey: _secureKeyController.text.isEmpty
                                        ? null
                                        : _secureKeyController.text,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorConst.primaryColor1,
                          padding: EdgeInsets.symmetric(
                            vertical: scrWidth * 0.04,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Transfer',
                                style: TextStyle(
                                  fontSize: scrWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, QRTransferResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: scrWidth * 0.06,
            ),
            SizedBox(width: scrWidth * 0.02),
            Text('Transfer Successful'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(response.message),
              SizedBox(height: scrWidth * 0.03),
              if (response.transactionId != null)
                Text('Transaction ID: ${response.transactionId}'),
              if (response.amount != null) Text('Amount: ₹${response.amount}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
