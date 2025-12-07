import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Constructor for the mobile field with title above the text field.
class mobileField extends StatelessWidget {
  final TextEditingController mobilePhoneController;
  const mobileField({super.key,required this.mobilePhoneController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0,left: 8),
      child: Container(
        width: MediaQuery.of(context).size.width*0.88,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Mobile Number",style: TextStyle(fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.width*0.03),),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.88,
                  height: MediaQuery.of(context).size.width*0.12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.02),
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    height: MediaQuery.of(context).size.width*0.1,
                    child: TextFormField(
                      controller: mobilePhoneController,
                      style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w400),
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.all(10),
                        hintText:"",
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13
                        ),
                        // border: UnderlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: Colors.grey
                        //   )
                        // ),

                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),


                        // focusedBorder: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                        //     // borderSide: BorderSide(color: Colors.black)
                        //     borderSide: BorderSide(color: colorConst.primaryColor)
                        // ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
