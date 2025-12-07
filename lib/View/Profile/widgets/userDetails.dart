


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/const/color_const.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../../main.dart';

/// Constructor for address details displaying within a box. The details are name, number and email

class userDetails extends StatelessWidget {
  const userDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state is UserLoaded ? state.user : null;
    return Container(
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scrWidth*0.01),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const  EdgeInsets.only(
          left: 16,
          right: 16,
          top: 22,
          bottom: 22,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.perm_identity_outlined,color: Colors.grey,size: 20,),
                SizedBox(
                  // width: scrWidth*0.4,
                  child: Row(
                    children: [
                      Text(
                        user?.fullName ?? 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.032,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.phone_outlined,color: Colors.grey,size: 20,),
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Text(
                          user?.phoneNumber ?? 'Phone',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.mail_outlined,color: Colors.grey,size: 20,),
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Text(
                          user?.email ?? 'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
