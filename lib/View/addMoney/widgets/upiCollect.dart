import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/const/color_const.dart';
import '../../../core/const/assets_const.dart';
import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appState.dart';
import '../../../main.dart';

/// Constructor for the upi collect button
class upiCollectButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const upiCollectButton({super.key, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(scrWidth * 0.02),
        child: Opacity(
          opacity: isLoading ? 0.7 : 1.0,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(scrWidth * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorConst.primaryColor1,
                  colorConst.primaryColor1.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(scrWidth * 0.02),
              boxShadow: [
                BoxShadow(
                  color: colorConst.primaryColor1.withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: scrWidth * 0.05,
                          ),
                          SizedBox(width: scrWidth * 0.02),
                          Text(
                            "UPI Collect",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: scrWidth * 0.04,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: scrWidth * 0.02),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: scrWidth * 0.02,
                              vertical: scrWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                scrWidth * 0.01,
                              ),
                            ),
                            child: Text(
                              "0% Charges",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: scrWidth * 0.028,
                              ),
                            ),
                          ),
                          SizedBox(width: scrWidth * 0.02),
                          Text(
                            "₹1 - ₹2000",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              fontSize: scrWidth * 0.028,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: scrWidth * 0.05,
                    height: scrWidth * 0.05,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  BlocBuilder<AppBloc, AppState>(
                    buildWhen: (previous, current) => current is AppLoaded,
                    builder: (context, state) {
                      String logoPath = "assets/images/ybs.jpeg";
                      if (state is AppLoaded && state.settings?.logo != null) {
                        logoPath =
                            "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                      }
                      return Container(
                        height: scrWidth * 0.12,
                        width: scrWidth * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(scrWidth * 0.02),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(scrWidth * 0.02),
                          child: logoPath.startsWith('http')
                              ? Image.network(
                                  logoPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/ybs.jpeg",
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  "assets/images/ybs.jpeg",
                                  fit: BoxFit.cover,
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
