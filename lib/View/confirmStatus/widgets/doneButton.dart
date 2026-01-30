import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../../navigationPage.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userEvent.dart';
import '../../../core/bloc/layoutBloc/layoutBloc.dart';
import '../../../core/bloc/layoutBloc/layoutEvent.dart';
import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appEvent.dart';
import '../../../core/bloc/dashboardBloc/dashboardBloc.dart';
import '../../../core/bloc/dashboardBloc/dashboardEvent.dart';
import '../../../core/bloc/notificationBloc/notificationBloc.dart';
import '../../../core/bloc/notificationBloc/notificationEvent.dart';

/// done button in confirm status screen
class doneButtonInConfirmStatus extends StatelessWidget {
  const doneButtonInConfirmStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Refresh home screen data before navigating
        try {
          final userBloc = context.read<UserBloc>();
          final layoutBloc = context.read<LayoutBloc>();
          final appBloc = context.read<AppBloc>();
          final dashboardBloc = context.read<DashboardBloc>();
          final notificationBloc = context.read<NotificationBloc>();
          
          userBloc.add(FetchUserDetailsEvent());
          layoutBloc.add(FetchLayoutsEvent());
          // Banners are already loaded on app startup and cached, no need to refetch
          // appBloc.add(FetchBannersEvent());
          appBloc.add(FetchNewsEvent());
          notificationBloc.add(const FetchNotificationStatsEvent());
          dashboardBloc.add(FetchDashboardStatistics(period: 'month'));
          
          print('🔄 [CONFIRM_STATUS] Refreshed home screen data before navigation');
        } catch (e) {
          print('⚠️ [CONFIRM_STATUS] Could not refresh home data: $e');
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => navigationPage(initialIndex: 0),
          ),
        );
      },
      child: Container(
        height: scrWidth*0.13,
        width: scrWidth*0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scrWidth*0.04),
            color: colorConst.primaryColor3
        ),
        child: Center(child: Text("Done",style: TextStyle(color: colorConst.white,fontWeight: FontWeight.bold,fontSize: scrWidth*0.035),)),
      ),
    );
  }
}
