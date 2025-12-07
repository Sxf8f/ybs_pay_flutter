import 'package:flutter/cupertino.dart';
import 'cornerBorderPainter.dart';


/// scanner border
class qrBorder extends StatelessWidget {
  const qrBorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: CornerBorderPainter(),
        child: Container(
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
