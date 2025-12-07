import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/const/color_const.dart';
import '../../../core/const/assets_const.dart';
import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appState.dart';
import '../../../core/bloc/appBloc/appEvent.dart';
import '../../../core/bloc/notificationBloc/notificationBloc.dart';
import '../../../core/bloc/notificationBloc/notificationEvent.dart';
import '../../../core/bloc/notificationBloc/notificationState.dart';
import '../../../main.dart';
import '../notification/notificationScreen.dart';

/// A StatelessWidget that represents the app bar used in the screens.

class appBar extends StatefulWidget implements PreferredSizeWidget {
  const appBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<appBar> createState() => _appBarState();
}

class _appBarState extends State<appBar> {
  @override
  void initState() {
    super.initState();
    // Fetch settings and notification stats once on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppBloc>().add(FetchSettingsEvent());
        context.read<NotificationBloc>().add(
          const FetchNotificationStatsEvent(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      // backgroundColor: _isNightMode?Colors.black: Colors.white,
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0, left: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<AppBloc, AppState>(
                  buildWhen: (previous, current) => current is AppLoaded,
                  builder: (context, state) {
                    if (state is AppLoaded && state.settings?.appLogo != null) {
                      final logoPath =
                          "${AssetsConst.apiBase}media/${state.settings!.appLogo!.image}";
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.05,
                        child: Row(
                          children: [
                            Image.network(
                              logoPath,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset("assets/images/ybs.jpeg");
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(
                      height: MediaQuery.of(context).size.width * 0.05,
                      child: Row(
                        children: [Image.asset("assets/images/ybs.jpeg")],
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    SizedBox(width: scrWidth * 0.02),

                    BlocBuilder<NotificationBloc, NotificationState>(
                      buildWhen: (previous, current) =>
                          current is NotificationStatsLoaded,
                      builder: (context, state) {
                        int unreadCount = 0;
                        if (state is NotificationStatsLoaded) {
                          unreadCount = state.stats.unreadNotifications;
                        }

                        return Stack(
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          notificationScreen(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.notifications,
                                  size: 30,
                                  color: colorConst.primaryColor1,
                                ),
                              ),
                            ),

                            if (unreadCount > 0)
                              Positioned(
                                top: scrWidth * 0.025,
                                right: scrWidth * 0.015,
                                child: CircleAvatar(
                                  backgroundColor: colorConst.primaryColor3,
                                  radius: scrWidth * 0.025,
                                  child: Center(
                                    child: Text(
                                      unreadCount > 99
                                          ? '99+'
                                          : unreadCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: scrWidth * 0.03,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
