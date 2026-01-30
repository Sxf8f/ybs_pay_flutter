


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../../main.dart';

/// Constructor for address details displaying within a box. The details are name, number and email

class userDetails extends StatelessWidget {
  const userDetails({super.key});

  Widget _buildSkeletonLoader() {
    return Container(
      width: scrWidth * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        color: Colors.transparent,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 22,
          bottom: 22,
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: scrWidth * 0.4,
                    height: scrWidth * 0.032,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: scrWidth * 0.4,
                    height: scrWidth * 0.032,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: scrWidth * 0.4,
                    height: scrWidth * 0.032,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return _buildSkeletonLoader();
        }
        final user = state is UserLoaded ? state.user : null;
        final scheme = Theme.of(context).colorScheme;
    return Container(
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scrWidth*0.01),
        color: scheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor,
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
                Icon(
                  Icons.perm_identity_outlined,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                  size: 20,
                ),
                SizedBox(
                  // width: scrWidth*0.4,
                  child: Row(
                    children: [
                      Text(
                        user?.fullName ?? 'User',
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
                  Icon(
                    Icons.phone_outlined,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    size: 20,
                  ),
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Text(
                          user?.phoneNumber ?? 'Phone',
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
                  Icon(
                    Icons.mail_outlined,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    size: 20,
                  ),
                  SizedBox(
                    // width: scrWidth*0.4,
                    child: Row(
                      children: [
                        Text(
                          user?.email ?? 'Email',
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
