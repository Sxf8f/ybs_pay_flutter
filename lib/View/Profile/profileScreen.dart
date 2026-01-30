import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/View/Profile/widgets/addressDetails.dart';
import 'package:ybs_pay/View/Profile/widgets/changePinPassword.dart';
import 'package:ybs_pay/View/Profile/widgets/regeneratePinPassword.dart';
import 'package:ybs_pay/View/Profile/widgets/doubleFactorButton.dart';
import 'package:ybs_pay/View/Profile/widgets/logOut.dart';
import 'package:ybs_pay/View/Profile/widgets/myQrCodeButton.dart';
import 'package:ybs_pay/View/Profile/widgets/prepaidWalletBalance.dart';
import 'package:ybs_pay/View/Profile/widgets/themeToggleButton.dart';
import 'package:ybs_pay/View/Profile/widgets/profileImage&Name.dart';
import 'package:ybs_pay/View/Profile/widgets/userDetails.dart';
import 'package:ybs_pay/View/widgets/app_bar.dart';
import 'package:ybs_pay/core/bloc/securityBloc/securityBloc.dart';
import 'package:ybs_pay/core/repository/securityRepository/securityRepo.dart';
import 'package:ybs_pay/core/bloc/userBloc/userBloc.dart';
import 'package:ybs_pay/core/bloc/userBloc/userState.dart';
import 'package:ybs_pay/View/Distributor/userManagement/userListScreen.dart';
import 'package:ybs_pay/View/Distributor/fundTransfer/fundTransferScreen.dart';
import 'package:ybs_pay/core/bloc/distributorBloc/distributorUserBloc.dart';
import 'package:ybs_pay/core/bloc/distributorBloc/distributorUserEvent.dart';
import 'package:ybs_pay/core/repository/distributorRepository/distributorRepo.dart';
import 'package:ybs_pay/main.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key});

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SecurityBloc(securityRepository: SecurityRepository()),
      child: Scaffold(
        appBar: appBar(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 15),

              ///Profile image, name and edit icon
              profileImageAndIcon(),

              /// Prepaid wallet balance container
              prepaidWalletBalance(),

              /// User details
              userDetails(),
              SizedBox(height: 16),

              /// Distributor-specific buttons
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoaded) {
                    final isDistributor = state.user.roleName.toLowerCase() == 'distributor' ||
                        (state.user.roleId != null && state.user.roleId == 2);
                    
                    if (isDistributor) {
                      return Column(
                        children: [
                          _buildProfileTileLikeMyQr(
                            context: context,
                            title: 'User List',
                            icon: Icons.people_outline,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (context) => DistributorUserBloc(
                                      DistributorRepository(),
                                    )..add(FetchUserListEvent()),
                                    child: UserListScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          _buildProfileTileLikeMyQr(
                            context: context,
                            title: 'Fund Transfer',
                            icon: Icons.swap_horiz,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FundTransferScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    }
                  }
                  return SizedBox.shrink();
                },
              ),

              /// My QR Code button
              myQrCodeButton(),
              SizedBox(height: 16),

              /// Theme Toggle
              // ThemeToggleButton(),
              // SizedBox(height: 16),

              /// Address Details
              addressDetails(),
              SizedBox(height: 16),

              /// Double factor button
              doubleFactorApi(),
              SizedBox(height: 0),

              /// Real API button
              // realApiButton(),
              // SizedBox(height: 0,),

              /// change password button
              // changePassword(),
              // SizedBox(height: 0,),

              ///change Pin Password
              changePinPassword(),

              /// Regenerate Pin Password
              RegeneratePinPassword(),

              /// logout
              logoutButton(),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  /// Matches the exact tile UI used by `myQrCodeButton()`
  /// so distributor tiles look identical.
  Widget _buildProfileTileLikeMyQr({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.14,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scrWidth * 0.02),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.shade300,
                blurRadius: 2,
                offset: Offset(3, 3),
                spreadRadius: 1,
              )
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: scrWidth * 0.04),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: MediaQuery.of(context).size.width * 0.032,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: scrWidth * 0.04),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).iconTheme.color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
