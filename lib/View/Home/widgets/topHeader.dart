import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/const/color_const.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../../main.dart';
import '../../addMoney/addMoney.dart';

/// A stack layout in the header of the app to display the profile details and shop name with the wallet balance also, and the add money button also.

class topHeader extends StatelessWidget {
  const topHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state is UserLoaded ? state.user : null;

        return Stack(
          children: [
            // SizedBox(height: scrWidth*0.5,),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: scrWidth * 0.35,
                width: scrWidth * 1,
                decoration: BoxDecoration(
                  color: colorConst.primaryColor1,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(
                      scrWidth * 0.9,
                      scrWidth * 0.09,
                    ),
                    bottomRight: Radius.elliptical(
                      scrWidth * 0.9,
                      scrWidth * 0.09,
                    ),
                    // bottomRight: Radius.circular(scrWidth*0.2)
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 30,
              child: SizedBox(
                width: scrWidth * 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade100,
                                minRadius:
                                    MediaQuery.of(context).size.width * 0.05,
                                maxRadius:
                                    MediaQuery.of(context).size.width * 0.06,
                                child: Image.asset(
                                  'assets/images/icons/profile.png',
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user?.fullName ?? 'User',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.034,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                    Text(
                                      ' - ${user?.roleName ?? 'Retailer'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.027,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  user?.outlet ?? 'Outlet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                        0.028,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          Text(
                            'Prepaid Wallet',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.028,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          Text(
                            '₹ ${user?.balance ?? '0.00'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.033,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: scrWidth * 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => addMoneyScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorConst.primaryColor3,
                          borderRadius: BorderRadius.circular(scrWidth * 0.05),
                          // borderRadius: BorderRadius.only(topRight: )
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 15,
                              left: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 7,
                                    left: 7,
                                  ),
                                  child: Icon(
                                    Icons.add_card_outlined,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                                Text(
                                  'Add Money',
                                  style: TextStyle(
                                    fontSize: scrWidth * 0.03,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
