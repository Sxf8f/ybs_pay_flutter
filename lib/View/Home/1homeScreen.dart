import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/View/Home/widgets/banner_slider.dart';
import 'package:ybs_pay/View/Home/widgets/home_app_bar.dart';
import 'package:ybs_pay/View/Home/widgets/scan&payButton.dart';
import 'package:ybs_pay/View/Home/widgets/status_amounts.dart';
import 'package:ybs_pay/View/Home/widgets/topHeader.dart';
import 'package:ybs_pay/View/Home/widgets/transactionHistory.dart';
import 'package:ybs_pay/core/const/assets_const.dart';

import '../../core/bloc/layoutBloc/layoutBloc.dart';
import '../../core/bloc/layoutBloc/layoutState.dart';
import '../../core/bloc/layoutBloc/layoutEvent.dart';
import '../../core/bloc/userBloc/userBloc.dart';
import '../../core/bloc/userBloc/userEvent.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appEvent.dart';
import '../../core/bloc/notificationBloc/notificationBloc.dart';
import '../../core/bloc/notificationBloc/notificationEvent.dart';
import '../../core/const/color_const.dart';
import '../../main.dart';

import '../testRechargePage.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen>
    with SingleTickerProviderStateMixin {
  void refreshHomeData() {
    // Refresh only the data, not the settings (logo)
    context.read<LayoutBloc>().add(FetchLayoutsEvent());
    context.read<UserBloc>().add(FetchUserDetailsEvent());
    context.read<AppBloc>().add(FetchBannersEvent());
    context.read<NotificationBloc>().add(const FetchNotificationStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(onRefresh: refreshHomeData),
      // backgroundColor: Colors.grey.shade100,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              /// Top header with profile image, user details and prepaid wallet balance.
              topHeader(),

              /// Banner with sliding images.
              BannerSlider(),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /// Status boxes like success, commission, pending and failed with amount
                    statusAmountsBox(),

                    /// Animated scan and pay button
                    ScanPayButton(),

                    BlocBuilder<LayoutBloc, LayoutState>(
                      builder: (context, state) {
                        if (state is LayoutLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is LayoutLoaded) {
                          final activeLayouts = state.layouts
                              .where((layout) => layout.isActive)
                              .toList();

                          return Container(
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.01,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [

                                    Padding(
                                      padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                            0.05,
                                        top:
                                            MediaQuery.of(context).size.width *
                                            0.05,
                                        bottom: MediaQuery.of(context).size.width * 0.05,
                                      ),
                                      child: Text(
                                        "Active Services",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: colorConst.primaryColor1,
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.03,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GridView.builder(
                                    physics: BouncingScrollPhysics(),
                                    itemCount: activeLayouts.length,
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 0.8,
                                          mainAxisSpacing: 2,
                                        ),
                                    itemBuilder: (context, index) {
                                      final layout = activeLayouts[index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  RechargePage(layout: layout),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.22,
                                          child: Column(
                                            children: [
                                              Container(
                                                height:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.16,
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.16,
                                                decoration: BoxDecoration(
                                                  color: colorConst.lightBlue,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      blurRadius: 10,
                                                      offset: Offset(0, 5),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.5,
                                                      ),
                                                ),
                                                child: layout.icon!.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.5,
                                                            ),
                                                        child: Image.network(
                                                          '${AssetsConst.apiBase}${layout.icon}',
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Icon(
                                                                  Icons
                                                                      .phone_android,
                                                                  color: Colors
                                                                      .black,
                                                                  size:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.width *
                                                                      0.08,
                                                                );
                                                              },
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.phone_android,
                                                        color: Colors.black,
                                                        size:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.08,
                                                      ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.03,
                                                ),
                                                child: Container(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.23,
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.1,
                                                  child: Text(
                                                    layout.operatorTypeName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.black,
                                                      fontSize:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.029,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is LayoutError) {
                          return Center(child: Text("Error: ${state.message}"));
                        }
                        return SizedBox();
                      },
                    ),

                    /// Services grid buttons like prepaid, postpaid, dth, landline etc..
                    // servicesGrid(),

                    /// Transaction History button
                    transactionHistory(),

                    SizedBox(height: scrWidth * 0.06),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
