import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// Constructor for the landmark field with title above the text field.
class landmarkField extends StatelessWidget {
  final TextEditingController landMarkController;
  const landmarkField({super.key, required this.landMarkController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0,left: 8),
      child: Container(
        width: MediaQuery.of(context).size.width*0.88,
        // height: scrWidth*0.23,
        // color: Colors.grey.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Landmark",style: TextStyle(fontWeight: FontWeight.w400,
                      // color: _isNightMode?Colors.white: Colors.black,
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
                      controller: landMarkController,
                      style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w400),
                      keyboardType: TextInputType.streetAddress,
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
