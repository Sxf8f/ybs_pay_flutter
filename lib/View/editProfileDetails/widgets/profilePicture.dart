import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;


import '../../../core/const/color_const.dart';
import '../../../main.dart';

/// Constructor for the profile picture picking and displaying the selected image name.
class profilePictureContainer extends StatefulWidget {
  const profilePictureContainer({super.key});

  @override
  State<profilePictureContainer> createState() => _profilePictureContainerState();
}

class _profilePictureContainerState extends State<profilePictureContainer> {
  var profilePicture;
  String? profilePictureImageName;

  editButtonDialogue() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(scrWidth*0.05)),
          content: Container(
            height: scrWidth*0.2,
            width: scrWidth*0.4,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(scrWidth*0.06),
                border: Border.all(
                    color: Colors.grey.shade300
                ),
                color: Colors.white
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     InkWell(
                //         onTap: () {
                //           Navigator.pop(context);
                //         },
                //         child: Icon(Icons.clear))
                //   ],
                // ),
                // Text('Select options to '),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        pickFile(ImageSource.camera);
                      },
                      child: Container(
                        height: scrWidth*0.15,
                        width: scrWidth*0.2,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(scrWidth*0.03),
                        ),
                        child: Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        pickFile(ImageSource.gallery);
                      },
                      child: Container(
                        height: scrWidth*0.15,
                        width: scrWidth*0.2,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(scrWidth*0.03),
                        ),
                        child: Icon(Icons.image),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("OK",style: TextStyle(
                  color: Colors.black,
                  fontSize: scrWidth*0.033
              ),),
              onPressed: () {
                Navigator.of(context).pop();},
            )
          ],
        );
      },
    );
  }
  pickFile(ImageSource) async {
    // Navigator.pop(context);
    final imgFile=await ImagePicker.platform.pickImage(source: ImageSource);
    if (imgFile != null) {

      profilePicture = File(imgFile.path);
      profilePictureImageName = path.basename(profilePicture.path);

      if (mounted) {
        setState(() {
          profilePicture = File(imgFile.path);
        });
        Navigator.pop(context);
        // await updateProfilePic(file!);
      }
    } else {
      print('No image selected.');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.88,
      // height: scrWidth*0.28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Profile Picture",style: TextStyle(fontWeight: FontWeight.w400,
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
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        editButtonDialogue();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        height: MediaQuery.of(context).size.width*0.14,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(MediaQuery.of(context).size.width*0.02),
                              bottomLeft: Radius.circular(MediaQuery.of(context).size.width*0.02),
                            ),
                            // border: Border.all(color: Colors.grey)
                            border: Border(right: BorderSide(color: Colors.grey))
                        ),
                        child: Center(
                          child: Text('Choose File',style: TextStyle(
                              fontSize: scrWidth*0.03,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                      ),
                    ),
                    profilePictureImageName!=null?
                    Row(
                      children: [
                        Text(
                          '   ${profilePictureImageName}'
                          ,style:TextStyle(
                            fontSize: 8
                        ) ,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                profilePicture=null;
                                profilePictureImageName=null;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: colorConst.grey)
                                ),
                                child: Center(child: Icon(Icons.close,size: 18,))),
                          ),
                        )
                      ],
                    ):
                    SizedBox.shrink()
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
