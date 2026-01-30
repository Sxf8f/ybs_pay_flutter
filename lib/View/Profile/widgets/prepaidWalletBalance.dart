import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/const/color_const.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../../main.dart';

class prepaidWalletBalance extends StatelessWidget {
  const prepaidWalletBalance({super.key});

  Widget _buildSkeletonLoader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(scrWidth * 0.025),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 22,
              bottom: 22,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: scrWidth * 0.4,
                  height: scrWidth * 0.03,
                  color: Colors.grey[300],
                ),
                Container(
                  width: scrWidth * 0.2,
                  height: scrWidth * 0.035,
                  color: Colors.grey[300],
                ),
              ],
            ),
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
          return _buildSkeletonLoader(context);
        }
        final user = state is UserLoaded ? state.user : null;
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 16,bottom: 16,left: 16,right: 16),
      child: Container(
        // height: MediaQuery.of(context).size.width*0.3,
        width: MediaQuery.of(context).size.width*1,
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.025),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const  EdgeInsets.only(
                left: 20,
                right: 20,
                top: 22,
                bottom: 22,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          "Prepaid Wallet Balance",
                          style: TextStyle(fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: MediaQuery.of(context).size.width*0.03),),
                      ),
                    ],
                  ),
                  Text(
                    "₹ ${user?.balance ?? '0.00'}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorConst.primaryColor3,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
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
