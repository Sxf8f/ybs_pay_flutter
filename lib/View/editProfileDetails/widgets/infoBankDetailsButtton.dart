import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

/// Constructor for the tab buttons - information, bank details and kyc.

class infoBankDetailsButton extends StatefulWidget {
  final Function(String) onTabChanged;
  const infoBankDetailsButton({super.key, required this.onTabChanged});

  @override
  State<infoBankDetailsButton> createState() => _infoBankDetailsButtonState();
}


class _infoBankDetailsButtonState extends State<infoBankDetailsButton> {
  bool information=true;
  bool bankDetails=false;
  bool kyc=false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0,left: 8,top: 8),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    information=true;
                    bankDetails=false;
                    kyc=false;
                  });
                  widget.onTabChanged('info');
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(scrWidth*0.04),
                        topLeft: Radius.circular(scrWidth*0.04),
                      ),
                      border: Border.all(
                          color: information?Colors.grey.shade400:Colors.transparent
                      ),
                      color: information?Colors.grey.shade100:Colors.transparent
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0,bottom: 8,right: 16,left: 16),
                    child: Text('Information',style: TextStyle(
                        fontSize: scrWidth*0.03,
                        color: information?Colors.black:colorConst.primaryColor3
                    ),),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    information=false;
                    bankDetails=true;
                    kyc=false;
                  });
                  widget.onTabChanged('bank');
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(scrWidth*0.04),
                        topLeft: Radius.circular(scrWidth*0.04),
                      ),
                      border: Border.all(
                          color: bankDetails?Colors.grey.shade400:Colors.transparent
                      ),
                      color: bankDetails?Colors.grey.shade100:Colors.transparent
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0,bottom: 8,right: 16,left: 16),
                    child: Text('Bank Details',style: TextStyle(
                        fontSize: scrWidth*0.03,
                        color: bankDetails?Colors.black:colorConst.primaryColor3
                    ),),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    information=false;
                    bankDetails=false;
                    kyc=true;
                  });
                  widget.onTabChanged('kyc');

                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(scrWidth*0.04),
                        topLeft: Radius.circular(scrWidth*0.04),
                      ),
                      border: Border.all(
                          color: kyc?Colors.grey.shade400:Colors.transparent
                      ),
                      color: kyc?Colors.grey.shade100:Colors.transparent
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0,bottom: 8,right: 16,left: 16),
                    child: Text('KYC',style: TextStyle(
                        fontSize: scrWidth*0.03,
                        color: kyc?Colors.black:colorConst.primaryColor3
                    ),),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0,left: 8),
          child: Divider(height: 0,),
        ),
      ],
    );
  }
}
