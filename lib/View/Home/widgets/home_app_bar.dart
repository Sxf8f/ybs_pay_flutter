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
import '../../notification/notificationScreen.dart';

/// A StatelessWidget that represents the app bar used in the home screen.
class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onRefresh;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  const HomeAppBar({
    super.key,
    this.onRefresh,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
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
      // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      iconTheme: Theme.of(context).appBarTheme.iconTheme,
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 1,
          child: Padding(
            padding: EdgeInsets.only(
              right: 18.0,
              left: widget.showBackButton ? 16.0 : 25.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.showBackButton) ...[
                      InkWell(
                        onTap:
                            widget.onBackPressed ??
                            () {
                              Navigator.pop(context);
                            },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    BlocBuilder<AppBloc, AppState>(
                      buildWhen: (previous, current) => current is AppLoaded,
                      builder: (context, state) {
                        String logoPath = "assets/images/ybs.jpeg";
                        if (state is AppLoaded &&
                            state.settings?.logo != null) {
                          logoPath =
                              "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                        }
                        return Container(
                          height: MediaQuery.of(context).size.width * 0.05,
                          child: Row(
                            children: [
                              logoPath.startsWith('http')
                                  ? Image.network(
                                      logoPath,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Image.asset(
                                              "assets/images/ybs.jpeg",
                                            );
                                          },
                                    )
                                  : Image.asset("assets/images/ybs.jpeg"),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
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
