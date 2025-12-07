import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class receiptScreen extends StatefulWidget {
  final providernum;
  final provideroperator;
  final provideramount;
  final providertransid;
  final providerdate;
  final providerstatus;

  const receiptScreen({
    super.key,
    required this.providernum,
    required this.provideroperator,
    required this.provideramount,
    required this.providertransid,
    required this.providerdate,
    required this.providerstatus,
  });

  @override
  State<receiptScreen> createState() => _receiptScreenState();
}

class _receiptScreenState extends State<receiptScreen> {
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Colors.white,
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
              width: 330,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/icons/logo ybs.png", height: 35),
                  const SizedBox(height: 10),
                  // const Divider(thickness: 1.5),
                  const Text(
                    'YBS PAY',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _infoRow('Mobile Number:', widget.providernum),
                  _infoRow('Operator:', widget.provideroperator),
                  _infoRow('Amount:', widget.provideramount),
                  _infoRow('TXN Id:', widget.providertransid),
                  _infoRow('Live Id:', 'N/A'),
                  _infoRow('Date:', widget.providerdate),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        widget.providerstatus,
                        style: TextStyle(
                          color: widget.providerstatus == 'SUCCESS'
                              ? Colors.green
                              : widget.providerstatus == 'FAILED'
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
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
