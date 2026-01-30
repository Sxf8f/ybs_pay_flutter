import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybs_pay/View/Home/widgets/home_app_bar.dart';
import 'package:ybs_pay/View/Home/widgets/scan&payButton.dart';
import 'package:ybs_pay/View/Home/widgets/status_amounts.dart';
import 'package:ybs_pay/View/Home/widgets/topHeader.dart';
import 'package:ybs_pay/View/Home/widgets/transactionHistory.dart';
import 'package:ybs_pay/View/Home/widgets/fundRequestButton.dart';
import 'package:ybs_pay/View/Home/widgets/banner_slider.dart';
import 'package:ybs_pay/View/Home/widgets/news_ticker.dart';
import 'package:ybs_pay/core/const/assets_const.dart';

import '../../core/bloc/layoutBloc/layoutBloc.dart';
import '../../core/bloc/layoutBloc/layoutState.dart';
import '../../core/bloc/layoutBloc/layoutEvent.dart';
import '../../core/bloc/userBloc/userBloc.dart';
import '../../core/bloc/userBloc/userEvent.dart';
import '../../core/bloc/userBloc/userState.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appEvent.dart';
import '../../core/bloc/notificationBloc/notificationBloc.dart';
import '../../core/bloc/notificationBloc/notificationEvent.dart';
import '../../core/bloc/dashboardBloc/dashboardBloc.dart';
import '../../core/bloc/dashboardBloc/dashboardEvent.dart';
import '../../core/repository/dashboardRepository/dashboardRepo.dart';
import '../../core/const/color_const.dart';
import '../../main.dart';

import '../testRechargePage.dart';
import '../Distributor/distributorDashboardScreen.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool? _cachedIsDistributor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCachedRole();
  }

  Future<void> _loadCachedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roleName = prefs.getString('role_name') ?? '';
      final roleId = prefs.getInt('role_id');

      _cachedIsDistributor =
          roleName.toLowerCase() == 'distributor' ||
          (roleId != null && roleId == 2);

      print(
        '🏠 [HomeScreen] Cached role loaded: roleName=$roleName, roleId=$roleId, isDistributor=$_cachedIsDistributor',
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('⚠️ [HomeScreen] Error loading cached role: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh user balance when app comes to foreground
      refreshHomeData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh only for retailer home. If this widget is currently acting as the
    // distributor entry point, DashboardBloc is not in scope and this call
    // will throw (ProviderNotFound) and cause visible jank.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // If role cache not loaded yet, don't do anything.
      if (_cachedIsDistributor == null) return;
      // If distributor, skip retailer-only refresh.
      if (_cachedIsDistributor == true) return;
      refreshBalanceAndStatsOnly();
    });
  }

  Future<void> _updateCachedRole(String? roleName, int? roleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (roleName != null) {
        await prefs.setString('role_name', roleName);
      }
      if (roleId != null) {
        await prefs.setInt('role_id', roleId);
      }

      final isDistributor =
          roleName?.toLowerCase() == 'distributor' ||
          (roleId != null && roleId == 2);

      if (_cachedIsDistributor != isDistributor) {
        _cachedIsDistributor = isDistributor;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('⚠️ [HomeScreen] Error updating cached role: $e');
    }
  }

  void refreshHomeData() {
    // Refresh only the data, not the settings (logo) or banners (already cached)
    context.read<LayoutBloc>().add(FetchLayoutsEvent());
    context.read<UserBloc>().add(FetchUserDetailsEvent());
    // Banners are already loaded on app startup and cached, no need to refetch
    // context.read<AppBloc>().add(FetchBannersEvent());
    print('📰 [HOME] Dispatching FetchNewsEvent in refreshHomeData...');
    context.read<AppBloc>().add(FetchNewsEvent());
    context.read<NotificationBloc>().add(const FetchNotificationStatsEvent());
    // DashboardBloc only exists for retailer home (it's created in the retailer branch).
    try {
      context.read<DashboardBloc>().add(FetchDashboardStatistics(period: 'month'));
    } catch (_) {
      print('! [HOME] Skipping dashboard refresh: DashboardBloc not in scope');
    }
  }

  void refreshBalanceAndStatsOnly() {
    // If distributor, this widget returns DistributorDashboardScreen() and
    // DashboardBloc is not provided. Skip to avoid ProviderNotFoundException.
    if (_cachedIsDistributor == true) {
      print('! [HOME] Skipping balance/stats refresh for distributor');
      return;
    }
    // Refresh only wallet balance and status amounts (success, commission, pending, failed)
    // This preserves profile picture and other data to avoid flashing
    context.read<UserBloc>().add(const RefreshBalanceOnlyEvent());
    try {
      context.read<DashboardBloc>().add(FetchDashboardStatistics(period: 'month'));
    } catch (_) {
      print('! [HOME] Could not refresh balance/stats: DashboardBloc not in scope');
    }
    print(
      '🔄 [HOME] Refreshed balance and stats only (preserved profile picture)',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // If cached role is still being loaded, show skeleton immediately
        if (_cachedIsDistributor == null) {
          print('🏠 [HomeScreen] Cached role not loaded yet, showing skeleton');
          return _buildHomeSkeletonLoader();
        }

        // Determine if user is distributor
        bool isDistributor = false;

        if (userState is UserLoaded) {
          // Use loaded user data
          isDistributor =
              userState.user.roleName.toLowerCase() == 'distributor' ||
              (userState.user.roleId != null && userState.user.roleId == 2);

          // Update cached role
          _updateCachedRole(userState.user.roleName, userState.user.roleId);
        } else if (userState is UserLoading || userState is UserInitial) {
          // Use cached role while loading to prevent glitch
          isDistributor = _cachedIsDistributor!;
          print(
            '🏠 [HomeScreen] Using cached role during loading: isDistributor=$isDistributor',
          );
        }

        print(
          '🏠 [HomeScreen] Building with userState: ${userState.runtimeType}, isDistributor: $isDistributor',
        );

        // Show distributor dashboard if user is distributor
        if (isDistributor) {
          return DistributorDashboardScreen();
        }

        return BlocProvider(
          create: (context) =>
              DashboardBloc(dashboardRepository: DashboardRepository())
                ..add(FetchDashboardStatistics(period: 'month')),
          child: PopScope(
            onPopInvoked: (didPop) {
              // Refresh only balance and stats when navigating back (preserves profile picture)
              if (!didPop) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    refreshBalanceAndStatsOnly();
                  }
                });
              }
            },
            child: Scaffold(
              appBar: HomeAppBar(),
              // backgroundColor: Colors.grey.shade100,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: RefreshIndicator(
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () async {
                    print('🔄 [HOME] Pull-to-refresh triggered');
                    // Refresh only balance and stats on pull-to-refresh (preserves profile picture)
                    refreshBalanceAndStatsOnly();
                    // Wait a bit for the refresh to complete
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: colorConst.primaryColor1,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        /// Top header with profile image, user details and prepaid wallet balance.
                        topHeader(),

                        /// News ticker (only shows if has_news = true)
                        Padding(
                          padding: const EdgeInsets.only(top: 9.0, bottom: 5.0),
                          child: NewsTicker(),
                        ),

                        /// Banner with sliding images (only shows if banners exist)
                        BannerSlider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: scrWidth * 0.04,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Status boxes like success, commission, pending and failed with amount
                              statusAmountsBox(),

                              /// Animated scan and pay button
                              ScanPayButton(),

                              BlocBuilder<LayoutBloc, LayoutState>(
                                builder: (context, state) {
                                  if (state is LayoutLoading) {
                                    return _buildLayoutSkeleton();
                                  } else if (state is LayoutLoaded) {
                                    final activeLayouts = state.layouts
                                        .where((layout) => layout.isActive)
                                        .toList();

                                    if (activeLayouts.isEmpty) {
                                      return SizedBox.shrink();
                                    }

                                    return Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          scrWidth * 0.01,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(
                                              scrWidth * 0.04,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(
                                                    scrWidth * 0.02,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: colorConst
                                                        .primaryColor1
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          scrWidth * 0.01,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.grid_view,
                                                    color: colorConst
                                                        .primaryColor1,
                                                    size: scrWidth * 0.04,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: scrWidth * 0.03,
                                                ),
                                                Text(
                                                  "Services",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                    fontSize: scrWidth * 0.033,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: scrWidth * 0.04,
                                              right: scrWidth * 0.04,
                                              bottom: scrWidth * 0.04,
                                            ),
                                            child: GridView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: activeLayouts.length,
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    childAspectRatio: 0.85,
                                                    crossAxisSpacing:
                                                        scrWidth * 0.02,
                                                    mainAxisSpacing:
                                                        scrWidth * 0.03,
                                                  ),
                                              itemBuilder: (context, index) {
                                                final layout =
                                                    activeLayouts[index];
                                                return Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              RechargePage(
                                                                layout: layout,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          scrWidth * 0.01,
                                                        ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          height:
                                                              scrWidth * 0.16,
                                                          width:
                                                              scrWidth * 0.16,
                                                          decoration: BoxDecoration(
                                                            color: colorConst
                                                                .lightBlue
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  scrWidth *
                                                                      0.5,
                                                                ),
                                                            border: Border.all(
                                                              color: colorConst
                                                                  .lightBlue
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child:
                                                              layout
                                                                  .icon!
                                                                  .isNotEmpty
                                                              ? Center(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(
                                                                      scrWidth *
                                                                          0.025,
                                                                    ),
                                                                    child: Image.network(
                                                                      '${AssetsConst.apiBase}${layout.icon}',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      width:
                                                                          scrWidth *
                                                                          0.12,
                                                                      height:
                                                                          scrWidth *
                                                                          0.12,
                                                                      errorBuilder:
                                                                          (
                                                                            context,
                                                                            error,
                                                                            stackTrace,
                                                                          ) {
                                                                            return Icon(
                                                                              Icons.phone_android,
                                                                              color: colorConst.primaryColor1,
                                                                              size:
                                                                                  scrWidth *
                                                                                  0.08,
                                                                            );
                                                                          },
                                                                    ),
                                                                  ),
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .phone_android,
                                                                  color: colorConst
                                                                      .primaryColor1,
                                                                  size:
                                                                      scrWidth *
                                                                      0.08,
                                                                ),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              scrWidth * 0.02,
                                                        ),
                                                        Text(
                                                          layout
                                                              .operatorTypeName,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black87,
                                                            fontSize:
                                                                scrWidth *
                                                                0.029,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          scrWidth * 0.04,
                                        ),
                                        child: Text(
                                          "Error: ${state.message}",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                },
                              ),

                              /// Services grid buttons like prepaid, postpaid, dth, landline etc..
                              // servicesGrid(),

                              /// Transaction History button
                              transactionHistory(),

                              /// Fund Request button
                              fundRequestButton(),

                              SizedBox(height: scrWidth * 0.08),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayoutSkeleton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(scrWidth * 0.04),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: scrWidth * 0.04,
                width: scrWidth * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: scrWidth * 0.04),
              Wrap(
                spacing: scrWidth * 0.02,
                runSpacing: scrWidth * 0.03,
                children: List.generate(8, (index) {
                  return Container(
                    width: (scrWidth * 0.92 - scrWidth * 0.06) / 4,
                    height: scrWidth * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(scrWidth * 0.01),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeSkeletonLoader() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Keep an app bar even during role-cache loading, so content never "jumps"
      // from the status bar area down after the real screen appears.
      appBar: HomeAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              /// Top header skeleton - use actual topHeader to maintain layout
              SizedBox(width: double.infinity, child: topHeader()),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: scrWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: scrWidth * 0.04),

                    /// Status boxes skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: scrWidth * 0.18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(width: scrWidth * 0.03),
                          Expanded(
                            child: Container(
                              height: scrWidth * 0.18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(width: scrWidth * 0.03),
                          Expanded(
                            child: Container(
                              height: scrWidth * 0.18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(width: scrWidth * 0.03),
                          Expanded(
                            child: Container(
                              height: scrWidth * 0.18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: scrWidth * 0.04),

                    /// Scan & Pay button skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: scrWidth * 0.14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: scrWidth * 0.04),

                    /// Services grid skeleton
                    _buildLayoutSkeleton(),

                    SizedBox(height: scrWidth * 0.04),

                    /// Transaction history skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: scrWidth * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: scrWidth * 0.08),
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
