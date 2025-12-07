import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';

/// Constructor for the qualification drop down.
class QualificationDropDown extends StatelessWidget {
  final String? selectedQualification;
  final List qualifications;
  final Function(String?) onChanged;

  const QualificationDropDown({
    super.key,
    required this.selectedQualification,
    required this.qualifications,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scrWidth = MediaQuery.of(context).size.width;

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
                  child: Text("Qualification",style: TextStyle(fontWeight: FontWeight.w400,
                      // color: _isNightMode?Colors.white: Colors.black,
                      fontSize: MediaQuery.of(context).size.width*0.03),),
                ),
                Container(
                  // color: Colors.grey,
                  width: MediaQuery.of(context).size.width*0.88,
                  height: scrWidth*0.13,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.02),
                    border: Border.all(color: Colors.grey),
                    color: colorConst.white,
                    // borderRadius: BorderRadius.circular(scrWidth * 0.03),
                    // border: Border.all(
                    // width: scrWidth * 0.0003,
                    //   color: colorConst.black.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            underline: SizedBox.shrink(),
                            dropdownColor: Colors.grey.shade100,
                            focusColor: colorConst.primaryColor1,
                            isDense: true,
                            icon: Icon(Icons.keyboard_arrow_down,color: Colors.transparent,),
                            // isExpanded: true,
                            // alignment: Alignment.center,
                            menuMaxHeight: MediaQuery.of(context).size.width*1,
                            menuWidth: MediaQuery.of(context).size.width*0.95,
                            style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w400),
                            value: selectedQualification,
                            hint: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Select Qualification',
                                style: TextStyle(
                                  fontSize: scrWidth * 0.033,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey.shade500,
                                  overflow: TextOverflow.visible,
                                  // fontSize: 11
                                ),),
                            ),
                            items: qualifications.map<DropdownMenuItem<String>>((qualifications) {
                              return DropdownMenuItem<String>(
                                value: qualifications['name'].toString(),
                                child: Text(qualifications['name']),
                              );
                            }).toList(),
                            onChanged: onChanged,
                          ),
                        ),
                      ],
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
