import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';


/// constructor for the tab buttons in the recharge screen
class TabButtons extends StatefulWidget {
  final Function(int index) onTabSelected;

  const TabButtons({super.key, required this.onTabSelected});

  @override
  State<TabButtons> createState() => _TabButtonsState();
}

class _TabButtonsState extends State<TabButtons> {
  int currentIndex = 0;

  void switchToPage(int index) {
    setState(() {
      currentIndex = index;
    });
    widget.onTabSelected(index);
  }
  Widget buildButton(String label, int index) {
    return ElevatedButton(
      onPressed: () => switchToPage(index),
      style: ElevatedButton.styleFrom(
        elevation: 3,
        backgroundColor: currentIndex == index ? colorConst.primaryColor1 : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          label,
          style: TextStyle(
            fontSize: scrWidth * 0.03,
            fontWeight: FontWeight.w500,
            color: currentIndex == index ? Colors.white : colorConst.primaryColor3,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: scrWidth*1,
      height: 60,
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildButton("Recharge", 0),
          buildButton("History", 1),
        ],
      ),
    );
  }
}

