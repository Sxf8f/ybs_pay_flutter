import 'package:flutter/cupertino.dart';

import '../../../main.dart';


/// constructor for the upi payee name displaying
class upiPayeeName extends StatefulWidget {
  final upiId;
  const upiPayeeName({super.key, required this.upiId});

  @override
  State<upiPayeeName> createState() => _upiPayeeNameState();
}

class _upiPayeeNameState extends State<upiPayeeName> {
  final TextEditingController amountController = TextEditingController(text: '');
  String _text = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.upiId != null) {
      print("✅ Scanned UPI: ${widget.upiId}");
      final uri = Uri.parse('${widget.upiId}');
      print(uri.queryParameters['pa']);
      print(uri.queryParameters['am']);
    }
    amountController.addListener(() {
      setState(() {
        _text = amountController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('${Uri.parse('${widget.upiId}').queryParameters['pn']}',style: TextStyle(
        fontSize: scrWidth*0.04,
        fontWeight: FontWeight.w600
    ),);
  }
}
