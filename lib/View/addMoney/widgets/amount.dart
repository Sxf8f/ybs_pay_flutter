import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';




/// Constructor for amount entering text field in adding money screen

class enterAmount extends StatefulWidget {
  final Function(TextEditingController)? onControllerCreated;

  const enterAmount({super.key, this.onControllerCreated});

  @override
  State<enterAmount> createState() => _enterAmountState();
}

class _enterAmountState extends State<enterAmount> {
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    // Notify parent about controller
    widget.onControllerCreated?.call(amountController);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter Amount",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            fontSize: scrWidth * 0.033,
          ),
        ),
        SizedBox(height: scrWidth * 0.03),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: amountController,
            style: TextStyle(
              fontSize: scrWidth * 0.033,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            cursorColor: colorConst.primaryColor1,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.all(scrWidth * 0.04),
                child: Text(
                  '₹',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: scrWidth * 0.033,
                    color: colorConst.primaryColor1,
                  ),
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                horizontal: scrWidth * 0.04,
                vertical: scrWidth * 0.04,
              ),
              hintText: "0.00",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: scrWidth * 0.033,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorConst.primaryColor1,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
