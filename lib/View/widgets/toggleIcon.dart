import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThreeDToggle extends StatefulWidget {
  @override
  _ThreeDToggleState createState() => _ThreeDToggleState();
}

class _ThreeDToggleState extends State<ThreeDToggle> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => isOn = !isOn),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          width: 40,
          height: 20,
          decoration: BoxDecoration(
            color: isOn ? Colors.green[400] : Colors.grey[300],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: isOn ? Offset(2, 2) : Offset(3, 3),
                blurRadius: 6,
              ),
              BoxShadow(
                color: Colors.white,
                offset: isOn ? Offset(-2, -2) : Offset(-4, -4),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 1),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}