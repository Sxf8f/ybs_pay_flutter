import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../test/test1.dart';
import '../../confirmStatus/confirmStatusScreen.dart';


/// amount field for the upi screen
class amountField extends StatefulWidget {
  const amountField({super.key});

  @override
  State<amountField> createState() => _amountFieldState();
}


class _amountFieldState extends State<amountField> {
  final TextEditingController amountController = TextEditingController();
  String _text = '';

  @override
  void initState() {
    super.initState();
    amountController.addListener(() {
      setState(() {
        _text = amountController.text;
      });
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  double _calculateTextWidth(String text) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text.isEmpty ? '0' : text,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return painter.size.width;
  }

  @override
  Widget build(BuildContext context) {
    final double textWidth = _calculateTextWidth(_text) + 95;
    print(textWidth);
    return Container(
      width: textWidth,
      child: TextFormField(
        controller: amountController,
        autofocus: true,
        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          IndianNumberFormatter(maxDigits: 6),
        ],
        textInputAction: TextInputAction.done,
        cursorColor: Colors.grey.shade700,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Text('₹', style: TextStyle(color: Colors.grey, fontSize: 25)),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: "0",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 25),
          border: OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(scrWidth * 0.04),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(scrWidth * 0.04),
          ),
        ),
        onFieldSubmitted: (value) {
          final rawNumber = amountController.text.replaceAll(',', '');
          if (int.tryParse(rawNumber) != null && int.parse(rawNumber) > 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => confirmStatus(amount: value)),
            );
          }
        },
      ),
    );
  }
}














class AmountField extends StatefulWidget {
  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  final TextEditingController _controller = TextEditingController();
  String _text = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _text = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.isEmpty ? '0' : text,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size.width;
  }

  @override
  Widget build(BuildContext context) {
    final textWidth = _calculateTextWidth(_text) + 80;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.all(16),
        width: textWidth.clamp(100.0, 300.0), // ← make sure it’s wide enough
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          inputFormatters: [IndianNumberFormatter(maxDigits: 6)],
          decoration: InputDecoration(
            prefixText: '₹ ',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}
