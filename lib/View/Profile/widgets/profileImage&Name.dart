import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../main.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../../core/bloc/userBloc/userEvent.dart';
import '../../editProfileDetails/editUserDetails.dart';

class profileImageAndIcon extends StatefulWidget {
  const profileImageAndIcon({super.key});

  @override
  State<profileImageAndIcon> createState() => _profileImageAndIconState();
}

class _profileImageAndIconState extends State<profileImageAndIcon> {
  Widget _buildProfileAvatar(String? profilePictureUrl) {
    final radius = MediaQuery.of(context).size.width * 0.1;
    return CircleAvatar(
      backgroundColor: Colors.grey.shade100,
      minRadius: radius,
      maxRadius: radius,
      child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: profilePictureUrl,
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                placeholder: (context, url) => Image.asset(
                  'assets/images/icons/profile.png',
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/icons/profile.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Image.asset(
              'assets/images/icons/profile.png',
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              minRadius: MediaQuery.of(context).size.width * 0.1,
              maxRadius: MediaQuery.of(context).size.width * 0.1,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: scrWidth * 0.3,
                    height: scrWidth * 0.04,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: scrWidth * 0.2,
                    height: scrWidth * 0.03,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: scrWidth * 0.12,
              height: scrWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(scrWidth * 0.02),
              ),
            ),
          ),
        ],
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
        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProfileAvatar(user?.profilePictureUrl),
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
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => editUserDetails()),
                    );
                    // Refresh user data if profile was updated
                    if (result == true && mounted) {
                      context.read<UserBloc>().add(FetchUserDetailsEvent());
                    }
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
