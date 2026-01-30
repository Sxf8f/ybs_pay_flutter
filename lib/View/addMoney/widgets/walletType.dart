import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/const/color_const.dart';
import '../../../core/bloc/walletBloc/walletBloc.dart';
import '../../../core/bloc/walletBloc/walletState.dart';
import '../../../core/models/walletModels/walletModel.dart';
import '../../../main.dart';


/// Constructor for the wallet type and balance
class walletType extends StatefulWidget {
  final WalletBalanceResponse? cachedBalance;
  
  const walletType({super.key, this.cachedBalance});

  @override
  State<walletType> createState() => _walletTypeState();
}

class _walletTypeState extends State<walletType> {
  WalletBalanceResponse? _lastBalance;

  @override
  void initState() {
    super.initState();
    _lastBalance = widget.cachedBalance;
  }

  @override
  void didUpdateWidget(walletType oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cachedBalance != null) {
      _lastBalance = widget.cachedBalance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        String? balanceText;
        bool isLoading = false;
        
        if (state is WalletBalanceLoaded) {
          balanceText = state.balance.balanceFormatted;
          _lastBalance = state.balance;
        } else if (state is WalletLoading) {
          isLoading = true;
          // Use cached balance if available while loading
          if (_lastBalance != null) {
            balanceText = _lastBalance!.balanceFormatted;
          }
        } else if (_lastBalance != null) {
          // Use cached balance if state doesn't have balance info
          balanceText = _lastBalance!.balanceFormatted;
        } else if (widget.cachedBalance != null) {
          // Use widget's cached balance as fallback
          balanceText = widget.cachedBalance!.balanceFormatted;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Wallet Balance",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: scrWidth * 0.033,
              ),
            ),
            SizedBox(height: scrWidth * 0.03),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(scrWidth * 0.05),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorConst.primaryColor1,
                    colorConst.primaryColor1.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorConst.primaryColor1.withOpacity(0.25),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prepaid Wallet',
                        style: TextStyle(
                          fontSize: scrWidth * 0.028,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: scrWidth * 0.015),
                      isLoading
                          ? Shimmer.fromColors(
                              baseColor: Colors.white.withOpacity(0.3),
                              highlightColor: Colors.white.withOpacity(0.5),
                              child: Container(
                                width: scrWidth * 0.25,
                                height: scrWidth * 0.04,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          : Text(
                              balanceText ?? '₹ 0.00',
                              style: TextStyle(
                                fontSize: scrWidth * 0.033,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(scrWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(scrWidth * 0.02),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: scrWidth * 0.06,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
