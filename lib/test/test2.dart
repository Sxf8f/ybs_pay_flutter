import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ZigzagReceiptScreen extends StatefulWidget {
  const ZigzagReceiptScreen({super.key});

  @override
  State<ZigzagReceiptScreen> createState() => _ZigzagReceiptScreenState();
}

class _ZigzagReceiptScreenState extends State<ZigzagReceiptScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _captureAndShare() async {
    final Uint8List? imageBytes = await _screenshotController.capture();
    if (imageBytes == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/receipt.png').create();
    await imagePath.writeAsBytes(imageBytes);

    await Share.shareXFiles([XFile(imagePath.path)], text: 'Your receipt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Receipt'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _captureAndShare,
          ),
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: _screenshotController,
          child: ClipPath(
            clipper: ZigZagClipper(),
            child: Container(
              width: 300,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('RECEIPT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Divider(thickness: 1.5),
                  _infoRow('Mobile Number:', '7012413339'),
                  _infoRow('Operator:', 'Google Play'),
                  _infoRow('Amount:', '₹150'),
                  _infoRow('Transaction Id:', '3294'),
                  _infoRow('Live Id:', '9FN2Y4K4KRW34NDA'),
                  _infoRow('Date:', '25-June-2025 | 01:06 pm'),
                  _infoRow('Status:', 'Success'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

class ZigZagClipper extends CustomClipper<Path> {
  final double zigzagHeight;
  final double zigzagWidth;

  ZigZagClipper({this.zigzagHeight = 10.0, this.zigzagWidth = 10.0});

  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Top zigzag
    path.moveTo(0, 0);
    for (double x = 0; x < size.width; x += zigzagWidth) {
      path.lineTo(x + zigzagWidth / 2, zigzagHeight);
      path.lineTo(x + zigzagWidth, 0);
    }

    // Right side
    path.lineTo(size.width, size.height - zigzagHeight);

    // Bottom zigzag
    for (double x = size.width; x > 0; x -= zigzagWidth) {
      path.lineTo(x - zigzagWidth / 2, size.height);
      path.lineTo(x - zigzagWidth, size.height - zigzagHeight);
    }

    // Close left side
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}







