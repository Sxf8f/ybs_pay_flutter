import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// constructor for upi user profile picture
class upiProfilePicture extends StatefulWidget {
  const upiProfilePicture({super.key});

  @override
  State<upiProfilePicture> createState() => _upiProfilePictureState();
}

class _upiProfilePictureState extends State<upiProfilePicture> {
  Map<String,dynamic> user={};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
            height:MediaQuery.of(context).size.width*0.27,
            child: user['image'] !=null ?
            // child:
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,  // Border color
                  width: 1.0,         // Border width
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: MediaQuery.of(context).size.width*0.2,
                backgroundImage: NetworkImage(user['image']),
              ),
            )
                :CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: MediaQuery.of(context).size.width*0.2,
              child: Icon(Icons.person,color: Colors.grey.shade500,size: 30,),
            )
        ),
      ],
    );
  }
}
