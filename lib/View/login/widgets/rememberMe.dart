import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

class rememberMe extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const rememberMe({super.key, required this.value, required this.onChanged});

  @override
  State<rememberMe> createState() => _rememberMeState();
}

class _rememberMeState extends State<rememberMe> {
  // bool remember=false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Center(
                  child: Checkbox(
                    splashRadius: 10,
                    value: widget.value,
                    onChanged: (value) {
                      setState(() {
                        widget.onChanged(value!);
                      });
                    },
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color:  Colors.grey.shade200
                        ),
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.018)),
                    activeColor: colorConst.primaryColor1,
                  ),

                ),
                InkWell(
                    onTap: () {
                      widget.onChanged(!widget.value);
                    },
                    child: Text("Remember me",style: TextStyle(
                        color: Colors.black,
                        fontSize: scrWidth*0.03,
                        fontWeight: FontWeight.w300),)
                ),
              ],
            ),
            InkWell(
              onTap: () {

              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text("Forgot password",
                  style: TextStyle(
                    // color: Colors.blue.shade700,
                    // color: colorConst.primaryColor1,
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth*0.028
                  ),),
              ),
            ),

          ],

        ),
      ),
    );
  }
}
