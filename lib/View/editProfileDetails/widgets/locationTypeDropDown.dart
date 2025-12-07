import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';


/// Constructor for the location type drop down.
class locationTypeDropDown extends StatelessWidget {
  final String? selectedLocationType;
  final List locationTypes;
  final Function(String?) onChanged;
  const locationTypeDropDown({super.key,required this.selectedLocationType,
    required this.locationTypes,required this.onChanged});

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
                  child: Text("Location Type",style: TextStyle(fontWeight: FontWeight.w400,
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
                            menuMaxHeight: MediaQuery.of(context).size.width*1,
                            menuWidth: MediaQuery.of(context).size.width*0.95,
                            style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w400),
                            value: selectedLocationType,
                            hint: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Select Location Type',
                                style: TextStyle(
                                  fontSize: scrWidth * 0.033,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey.shade500,
                                  overflow: TextOverflow.visible,
                                  // fontSize: 11
                                ),),
                            ),
                            items: locationTypes.map<DropdownMenuItem<String>>((locType) {
                              return DropdownMenuItem<String>(
                                value: locType['name'].toString(),
                                child: Text(locType['name']),
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
