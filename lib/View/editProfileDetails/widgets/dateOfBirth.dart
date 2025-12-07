import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:intl/intl.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

/// Constructor for the date of birth.
class dateOfBirthDialogue extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  const dateOfBirthDialogue({Key? key, required this.onDateSelected, required initialDate}) : super(key: key);

  @override
  State<dateOfBirthDialogue> createState() => _dateOfBirthDialogueState();
}

class _dateOfBirthDialogueState extends State<dateOfBirthDialogue> {
  DateTime? selectedDob;
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
                  child: Text("Date of Birth",style: TextStyle(fontWeight: FontWeight.w400,
                      // color: _isNightMode?Colors.white: Colors.black,
                      fontSize: MediaQuery.of(context).size.width*0.03),),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.88,
                  height: MediaQuery.of(context).size.width*0.12,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.02),
                      border: Border.all(color: Colors.grey.shade400)
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text('Select Date of Birth',style: TextStyle(
                                fontSize: scrWidth*0.035,color: colorConst.primaryColor3
                            ),),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DatePickerWidget(
                                    looping: false, // Whether to enable infinite scrolling
                                    firstDate: DateTime(1920),
                                    lastDate: DateTime(2060),
                                    initialDate: DateTime.now(),
                                    dateFormat: "dd-MMMM-yyyy",
                                    onChange: (DateTime newDate, _) {
                                      setState(() {
                                        selectedDob = newDate;
                                      });
                                    },
                                    pickerTheme: DateTimePickerTheme(
                                      itemTextStyle: TextStyle(color: Colors.black, fontSize: 18),
                                      dividerColor: colorConst.primaryColor3,
                                    ),
                                  ),
                                  SizedBox(height: 10,),

                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    // print(selectedDate);
                                    selectedDob=selectedDob??DateTime.now();
                                  });
                                  widget.onDateSelected(selectedDob ?? DateTime.now());
                                  Navigator.of(context).pop();
                                },
                                child: Text('Done',style: TextStyle(
                                    color: Colors.black,
                                    fontSize: scrWidth*0.03
                                ),),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedDob==null?'Select Date'
                                :
                            DateFormat('yyyy-MM-dd').format(selectedDob??DateTime.now())}',
                            style: TextStyle(
                                fontWeight: selectedDob==null?FontWeight.w300:FontWeight.w400,
                                fontSize: selectedDob==null?scrWidth*0.033:13,
                                color: selectedDob==null?Colors.grey.shade500:Colors.black
                            ),
                          ),
                        ],
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
