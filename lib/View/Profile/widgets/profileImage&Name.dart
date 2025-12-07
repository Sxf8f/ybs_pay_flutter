import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../editProfileDetails/editUserDetails.dart';

class profileImageAndIcon extends StatefulWidget {
  const profileImageAndIcon({super.key});

  @override
  State<profileImageAndIcon> createState() => _profileImageAndIconState();
}

class _profileImageAndIconState extends State<profileImageAndIcon> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state is UserLoaded ? state.user : null;
        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    minRadius: MediaQuery.of(context).size.width * 0.1,
                    maxRadius: MediaQuery.of(context).size.width * 0.1,
                    child: Image.asset('assets/images/icons/profile.png'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        // color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    Text(
                      user?.roleName ?? 'Role',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(17.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => editUserDetails()));
                  },
                  child: Container(
                    // color: Colors.grey.shade300,
                    // height: MediaQuery.of(context).size.width*0.1,
                    // width: MediaQuery.of(context).size.width*0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(scrWidth * 0.02),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 2,
                          // blurStyle: BlurStyle.outer,
                          offset: Offset(2, 2),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(scrWidth * 0.015),
                      child: Icon(
                        Icons.edit_note_outlined,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
