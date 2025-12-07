import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/accHolderNameField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/accNumberField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/addressField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/adharField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/alternativeMobileField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/appBarEditUserDetails.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/containerBackground.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/dateOfBirth.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/emailField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/gstField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/ifscField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/infoBankDetailsButtton.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/landmarkField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/locationTypeDropDown.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/mobileField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/nameField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/outletNameField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/panNumberField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/pinCodeField.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/populationDropDown.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/profilePicture.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/qualificationDropDown.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/shopTypeDropDown.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/updateBankDetails.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/updateKYC.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/updateProfileButton.dart';
import 'package:ybs_pay/View/widgets/bankDropDown.dart';

import '../../core/const/color_const.dart';
import '../../main.dart';
import 'package:path/path.dart' as path;


class editUserDetails extends StatefulWidget {
  const editUserDetails({super.key});

  @override
  State<editUserDetails> createState() => _editUserDetailsState();
}

class _editUserDetailsState extends State<editUserDetails> {
/// information controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController outletNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController alternateMobileNumberController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
/// bank details controllers
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accNoController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accHolderController = TextEditingController();
  final TextEditingController branchIdController = TextEditingController();
/// kyc controllers
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController panController = TextEditingController();
/// tab button bool values
  bool information=true;
  bool bankDetails=false;
  bool kyc=false;
  ///drop down lists with data's
  List qualifications=[
    {
      'name':'SSLC',
    },
    {
      'name':'HSC',
    },
    {
      'name':'Graduate',
    },
    {
      'name':'Post Graduate',
    },
    {
      'name':'Diploma',
    },
  ];
  List populations = [
    {
      'name':'0 to 2000',
    },
    {
      'name':'2000 to 5000',
    },
    {
      'name':'5000 to 10000',
    },
    {
      'name':'10000 to 50000',
    },
    {
      'name':'50000 to 100000',
    },
    {
      'name':'100000+',
    },

  ];
  List shopTypes = [
    {
      'name':'KIRANA SHOP',
    },
    {
      'name':'MOBILE SHOP',
    },
    {
      'name':'COPIER SHOP',
    },
    {
      'name':'INTERNET CAFE',
    },

  ];
  List locationTypes = [
    {
      'name':'Rural',
    },
    {
      'name':'Urban',
    },
    {
      'name':'Metro',
    },
    {
      'name':'Semi Urban',
    },

  ];
  List bankName = [
    {
      'name':'HDFC LTD',
    },
    {
      'name':'SBI',
    },
    {
      'name':'SOUTH INDIAN BANK',
    },

  ];
  ///selected dropdown values
  String? selectedBank;
  String? selectedQualification;
  String? selectedPopulation;
  String? selectedShopType;
  String? selectedLocationType;
  /// selected date of birth in DateTime format
  DateTime? selectedDob;
  /// picture variable for profile picture picking
  var profilePicture;
  /// String profile picture name to display the selected picture name
  String? profilePictureImageName;
  /// The default selected tab
  String selectedTab = 'info';
  /// initial date for the date picker
  DateTime? _userDob;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// app bar in the edit screen
      appBar: appBarEditScreen(),

      backgroundColor: Colors.white,

      body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SizedBox(
                width: scrWidth*1,
              child: Column(
                children: [

                  /// Background container with a shadow curved box layout
                  backgroundContainer(
                    Widgets: [
                      infoBankDetailsButton(
                        onTabChanged: (value) {
                          setState(() {
                            selectedTab = value;
                          });
                        }),

                      /// information tab
                      if (selectedTab == 'info') Column(
                          children:[

                            SizedBox(height: 20),

                            /// profile picture selection with picked picture name displaying
                            profilePictureContainer(),


                            SizedBox(height: 30),

                            /// name field
                            nameField(nameController: nameController),

                            /// outlet name field
                            outletNameField(outletNameController: outletNameController,),

                            /// mobile field
                            mobileField(mobilePhoneController: mobileNumberController,),

                            /// alternative mobile field
                            alternativeMobileField(alternativeMobileNumberController: alternateMobileNumberController,),

                            SizedBox(height: 50),

                            /// email field
                            emailField( emailIdController: emailIdController,),

                            /// pin code field
                            pinCodeField(pinCodeController: pinCodeController,),

                            /// address field
                            addressField(addressController: addressController,),

                            /// landmark field
                            landmarkField(landMarkController: landmarkController,),

                            /// gst field
                            gstField(gstController: gstController,),

                            SizedBox(height: 50),

                            /// date picker for date of birth
                            dateOfBirthDialogue(
                              initialDate: _userDob,
                              onDateSelected: (date) {
                                setState(() {
                                  _userDob = date;
                                });
                              },
                            ),

                            /// drop down for qualification selection
                            QualificationDropDown(
                              selectedQualification: selectedQualification,
                              qualifications: qualifications,
                              onChanged: (value) {
                                setState(() {
                                  selectedQualification = value;
                                });
                              },
                            ),

                            /// drop down for population selection
                            populationDropDown(
                              selectedPopulation: selectedPopulation,
                              populations: populations,
                              onChanged: (value) {
                                setState(() {
                                  selectedPopulation=value;
                                });
                              },
                            ),

                            /// drop down for shop type selection
                            shopTypeDropDown(
                              selectedShopType:selectedShopType,
                                shopTypes: shopTypes,
                              onChanged: (value) {
                              setState(() {
                                selectedShopType=value;
                              });
                              }
                            ),

                            /// drop down for location type selection
                            locationTypeDropDown(
                                selectedLocationType :selectedLocationType,
                                locationTypes: locationTypes,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLocationType=value;
                                  });
                                }
                            ),
                            SizedBox(height: 50),

                            /// update profile container button
                            updateProfileButton()




                            ]
                      ),
                      /// bank details tab
                      if (selectedTab == 'bank') Column(
                          children:[
                            SizedBox(height: 20),

                            /// drop down selection for bank names
                            bankDropDown(
                              selectedBank: selectedBank,
                              banks: bankName, onChanged: (value) {
                              setState(() {
                                selectedBank=value;
                              });
                            },),

                            /// account number field
                            accField(accountNumberController: accNoController,),

                            /// ifsc code field
                            ifscField(ifscController: ifscController),

                            /// account holder name field
                            accHolderNameField(accHolderNameController: accHolderController,),

                            /// update bank details button
                            updateBankDetails()

                          ]
                      ),

                      /// kyc tab
                      if (selectedTab == 'kyc') Column(
                          children:[
                            SizedBox(height: 20),

                            /// adhar number field
                            adharField(adharNumberController: aadharController),

                            /// pan number field
                            panNumberField(panNumberController: panController),

                            /// update button
                            updateKyc()
                          ]
                      ),
                  ],
                  ),
                  SizedBox(height: scrWidth*0.1,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
