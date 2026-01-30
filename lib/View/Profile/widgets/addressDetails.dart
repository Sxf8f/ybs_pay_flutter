import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../../main.dart';

/// Constructor for address details displaying within a box. The details are name, number and email

class addressDetails extends StatelessWidget {
  const addressDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state is UserLoaded ? state.user : null;
        final scheme = Theme.of(context).colorScheme;
    return Container(
      // color: Colors.grey.shade300,
      // height: MediaQuery.of(context).size.width*0.14,
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scrWidth*0.01),
        color: scheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        // boxShadow: [
        //   BoxShadow(
        //       color: Colors.grey.shade300,
        //       blurRadius: 2,
        //       // blurStyle: BlurStyle.outer,
        //       offset: Offset(4, 4),
        //       spreadRadius: 1
        //
        //   )
        // ]
      ),
      child: Padding(
        padding: const  EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 22,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Address  ',style: TextStyle(
                      fontSize: scrWidth*0.034,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),),
                  Icon(
                    Icons.home_work_outlined,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  )
                ],
              ),
            ),
            Divider(color: Theme.of(context).dividerColor,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Address",
                  style: TextStyle(fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: MediaQuery.of(context).size.width*0.032),),
                SizedBox(
                  // width: scrWidth*0.4,
                  child: Row(
                    children: [
                      Text(
                        user?.address ?? 'Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  Text(
                    "Pin code",
                    style: TextStyle(fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: MediaQuery.of(context).size.width*0.032),),
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Text(
                          user?.pincode ?? 'Pincode',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  Text(
                    "City",
                    style: TextStyle(fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: MediaQuery.of(context).size.width*0.032),),
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Text(
                          "N/A",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  Text(
                    "State",
                    style: TextStyle(fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: MediaQuery.of(context).size.width*0.032),),
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Text(
                          "N/A",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
