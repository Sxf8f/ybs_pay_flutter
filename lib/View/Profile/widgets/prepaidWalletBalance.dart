import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/const/color_const.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';

class prepaidWalletBalance extends StatelessWidget {
  const prepaidWalletBalance({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state is UserLoaded ? state.user : null;
    return Padding(
      padding: const EdgeInsets.only(top: 16,bottom: 16,left: 16,right: 16),
      child: Container(
        // height: MediaQuery.of(context).size.width*0.3,
        width: MediaQuery.of(context).size.width*1,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                      Icon(Icons.account_balance_wallet,color: Colors.black,),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          "Prepaid Wallet Balance",
                          style: TextStyle(fontWeight: FontWeight.w500,
                              color: Colors.black,
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
