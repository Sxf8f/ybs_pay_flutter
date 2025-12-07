import 'package:flutter/material.dart';
import '../../../core/const/color_const.dart';
import '../../scanQr/scanqrScreen.dart';



/// Constructor for the animated scan and pay button


class ScanPayButton extends StatefulWidget {
  const ScanPayButton({super.key});

  @override
  State<ScanPayButton> createState() => _ScanPayButtonState();
}

class _ScanPayButtonState extends State<ScanPayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return GestureDetector(
          // autofocus: false,
          // hoverColor: Colors.transparent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => scanQrScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                gradient: LinearGradient(
                  colors: [
                    colorConst.lightBlue,
                    Colors.white,
                    colorConst.lightBlue
                  ],
                  stops: [
                    (_controller.value - 0.3).clamp(0.0, 1.0),
                    _controller.value.clamp(0.0, 1.0),
                    (_controller.value + 0.3).clamp(0.0, 1.0),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_scanner_outlined, color: Colors.black),
                    SizedBox(height: 8),
                    Text('Scan & Pay',
                        style: TextStyle(fontSize: 11, color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
