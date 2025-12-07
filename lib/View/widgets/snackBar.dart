import 'package:flutter/material.dart';

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.2),
      ),
      duration: Duration(seconds: 1),
    ),
  );
}

