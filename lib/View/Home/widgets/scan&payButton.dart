import 'package:flutter/material.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
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
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  double _getScale() {
    // Gentle pulse: scales between 1.0 and 1.02 (2% increase)
    return 1.0 + (_controller.value * 0.02);
  }

  double _getTranslateY() {
    // Subtle vertical movement: moves between 0 and -2 pixels
    return -(_controller.value * 2.0);
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => scanQrScreen()),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: scrWidth * 0.04,
              bottom: scrWidth * 0.06,
            ),
            child: Transform.scale(
              scale: _getScale(),
              child: Transform.translate(
                offset: Offset(0, _getTranslateY()),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorConst.primaryColor1,
                        colorConst.primaryColor1.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorConst.primaryColor1.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(scrWidth * 0.01),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: scrWidth * 0.04,
                      horizontal: scrWidth * 0.06,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(scrWidth * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_outlined,
                            color: Colors.white,
                            size: scrWidth * 0.05,
                          ),
                        ),
                        SizedBox(width: scrWidth * 0.03),
                        Text(
                          'Scan & Pay',
                          style: TextStyle(
                            fontSize: scrWidth * 0.033,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
