import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/bloc/distributorBloc/distributorDashboardBloc.dart';
import '../../core/bloc/distributorBloc/distributorDashboardEvent.dart';
import '../../core/bloc/distributorBloc/distributorDashboardState.dart';
import '../../core/models/distributorModels/distributorDashboardModel.dart';
import '../../core/bloc/userBloc/userBloc.dart';
import '../../core/bloc/userBloc/userEvent.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appEvent.dart';
import '../../core/const/color_const.dart';
import '../../main.dart';
import '../../../View/widgets/app_bar.dart';
import '../Home/widgets/topHeader.dart';
import '../Home/widgets/banner_slider.dart';
import '../Home/widgets/news_ticker.dart';
import 'userManagement/userListScreen.dart';
import 'fundTransfer/fundTransferScreen.dart';
import 'scanPay/distributorScanPayScreen.dart';
import '../../core/bloc/distributorBloc/distributorUserBloc.dart';
import '../../core/bloc/distributorBloc/distributorUserEvent.dart';
import '../../core/repository/distributorRepository/distributorRepo.dart';
import '../../core/bloc/distributorBloc/distributorReportBloc.dart';
import '../../View/Distributor/reports/userLedgerScreen.dart';

class DistributorDashboardScreen extends StatefulWidget {
  const DistributorDashboardScreen({super.key});

  @override
  State<DistributorDashboardScreen> createState() =>
      _DistributorDashboardScreenState();
}

class _DistributorDashboardScreenState
    extends State<DistributorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint(
        '📊 [DistributorDashboardScreen] initState() -> dispatch FetchDistributorDashboardEvent',
      );
    }
    // Fetch dashboard data when screen loads
    context.read<DistributorDashboardBloc>().add(
      FetchDistributorDashboardEvent(),
    );
    // Fetch banners and news
    // Banners are already loaded on app startup and cached, no need to refetch
    // context.read<AppBloc>().add(FetchBannersEvent());
    context.read<AppBloc>().add(FetchNewsEvent());
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('📊 [DistributorDashboardScreen] build()');
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: BlocBuilder<DistributorDashboardBloc, DistributorDashboardState>(
        builder: (context, state) {
          if (kDebugMode) {
            debugPrint(
              '📊 [DistributorDashboardScreen] BlocBuilder state=${state.runtimeType}',
            );
          }
          if (state is DistributorDashboardLoading) {
            if (kDebugMode) {
              debugPrint(
                '📊 [DistributorDashboardScreen] -> showing dashboard skeleton',
              );
            }
            return _buildSkeletonLoader();
          }

          if (state is DistributorDashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DistributorDashboardBloc>().add(
                          FetchDistributorDashboardEvent(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorConst.primaryColor1,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DistributorDashboardLoaded ||
              state is DistributorDashboardRefreshing) {
            final dashboardResponse = state is DistributorDashboardLoaded
                ? state.dashboard
                : (state as DistributorDashboardRefreshing).dashboard;
            final dashboard = dashboardResponse.data;
            final isRefreshing = state is DistributorDashboardRefreshing;

            final content = RefreshIndicator(
              onRefresh: () async {
                if (kDebugMode) {
                  debugPrint(
                    '🔄 [DistributorDashboardScreen] pull-to-refresh -> refetch dashboard + user',
                  );
                }
                // Refresh dashboard data
                context.read<DistributorDashboardBloc>().add(
                  FetchDistributorDashboardEvent(),
                );
                // Refresh user data (for topHeader)
                context.read<UserBloc>().add(FetchUserDetailsEvent());
                // Wait a bit for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: colorConst.primaryColor1,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Header
                    SizedBox(width: double.infinity, child: topHeader()),

                    /// News ticker (only shows if has_news = true)
                    Padding(
                      padding: const EdgeInsets.only(top: 9.0, bottom: 5.0),
                      child: NewsTicker(),
                    ),

                    /// Banner with sliding images (only shows if banners exist)
                    BannerSlider(),

                    // Main Content
                    Padding(
                      padding: EdgeInsets.all(scrWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Dashboard Stats Cards
                          _buildStatsCards(dashboard),

                          SizedBox(height: scrWidth * 0.05),

                          /// Quick Actions
                          _buildQuickActions(),

                          SizedBox(height: scrWidth * 0.05),

                          /// Today's Report Chart
                          if (dashboard.todaysReport != null)
                            _buildTodaysReport(dashboard.todaysReport!),

                          SizedBox(height: scrWidth * 0.05),

                          /// Role Summary (if available)
                          // if (dashboard.roleSummary.isNotEmpty)
                          //   _buildRoleSummary(dashboard.roleSummary),
                          SizedBox(height: scrWidth * 0.06),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (!isRefreshing) return content;

            // Keep content visible and show a subtle progress bar at the top.
            return Stack(
              children: [
                content,
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              ],
            );
          }

          return _buildSkeletonLoader();
        },
      ),
    );
  }

  Widget _buildStatsCards(DistributorDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Container(
          padding: EdgeInsets.only(bottom: scrWidth * 0.03),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.025),
                decoration: BoxDecoration(
                  color: colorConst.primaryColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(scrWidth * 0.01),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: colorConst.primaryColor1,
                  size: scrWidth * 0.05,
                ),
              ),
              SizedBox(width: scrWidth * 0.03),
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: scrWidth * 0.04,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: scrWidth * 0.03,
          crossAxisSpacing: scrWidth * 0.03,
          childAspectRatio: 1.1,
          children: [
            _buildStatCard(
              'Balance',
              '₹${dashboard.balance.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              colorConst.primaryColor1,
            ),
            _buildStatCard(
              'Today\'s Purchase',
              '₹${dashboard.todaysPurchase.toStringAsFixed(2)}',
              Icons.shopping_cart,
              Colors.blue,
            ),
            _buildStatCard(
              'Today\'s Earning',
              '₹${dashboard.todaysEarning.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.green,
            ),
            _buildStatCard(
              'Pending Purchase',
              '₹${dashboard.pendingPurchase.toStringAsFixed(2)}',
              Icons.pending,
              Colors.orange,
            ),
          ],
        ),
        SizedBox(height: scrWidth * 0.03),
        _buildStatCard(
          'Today\'s Fund Transfer',
          '₹${dashboard.todaysFundTransfer.toStringAsFixed(2)}',
          Icons.swap_horiz,
          Colors.purple,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.015),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: scrWidth * 0.05),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: scrWidth * 0.02),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: scrWidth * 0.032,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          Text(
            value,
            style: TextStyle(
              fontSize: scrWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysReport(TodaysReport report) {
    return Container(
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.025),
                decoration: BoxDecoration(
                  color: colorConst.primaryColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(scrWidth * 0.01),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: colorConst.primaryColor1,
                  size: scrWidth * 0.05,
                ),
              ),
              SizedBox(width: scrWidth * 0.03),
              Text(
                'Today\'s Report',
                style: TextStyle(
                  fontSize: scrWidth * 0.04,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.03),
          if (report.labels.isNotEmpty && report.values.isNotEmpty)
            Container(
              height: scrWidth * 0.4,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: report.labels.length,
                itemBuilder: (context, index) {
                  final maxValue = report.values.reduce(
                    (a, b) => a > b ? a : b,
                  );
                  final height = maxValue > 0
                      ? (report.values[index] / maxValue) * scrWidth * 0.35
                      : 0.0;
                  return Container(
                    margin: EdgeInsets.only(right: scrWidth * 0.02),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: scrWidth * 0.06,
                          height: height,
                          decoration: BoxDecoration(
                            color: colorConst.primaryColor1,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: scrWidth * 0.01),
                        Text(
                          report.labels[index],
                          style: TextStyle(
                            fontSize: scrWidth * 0.025,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildRoleSummary(List<RoleSummary> roleSummary) {
    return Container(
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.025),
                decoration: BoxDecoration(
                  color: colorConst.primaryColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(scrWidth * 0.01),
                ),
                child: Icon(
                  Icons.people_outline,
                  color: colorConst.primaryColor1,
                  size: scrWidth * 0.05,
                ),
              ),
              SizedBox(width: scrWidth * 0.03),
              Text(
                'Role Summary',
                style: TextStyle(
                  fontSize: scrWidth * 0.04,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.03),
          ...roleSummary.map(
            (summary) => Padding(
              padding: EdgeInsets.only(bottom: scrWidth * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    summary.roleName,
                    style: TextStyle(
                      fontSize: scrWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      _buildSummaryItem(
                        'Status',
                        summary.totalStatus.toString(),
                      ),
                      SizedBox(width: scrWidth * 0.04),
                      _buildSummaryItem(
                        'Transactions',
                        summary.totalTxns.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: scrWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: colorConst.primaryColor1,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: scrWidth * 0.028, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Container(
          padding: EdgeInsets.only(bottom: scrWidth * 0.03),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.025),
                decoration: BoxDecoration(
                  color: colorConst.primaryColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(scrWidth * 0.01),
                ),
                child: Icon(
                  Icons.dashboard_outlined,
                  color: colorConst.primaryColor1,
                  size: scrWidth * 0.05,
                ),
              ),
              SizedBox(width: scrWidth * 0.03),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: scrWidth * 0.04,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: scrWidth * 0.03,
          crossAxisSpacing: scrWidth * 0.03,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              'User List',
              Icons.people_outline,
              colorConst.primaryColor1,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) =>
                          DistributorUserBloc(DistributorRepository())
                            ..add(FetchUserListEvent()),
                      child: UserListScreen(),
                    ),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Fund Transfer',
              Icons.swap_horiz,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FundTransferScreen()),
                );
              },
            ),
            _buildActionCard(
              'Scan & Pay',
              Icons.qr_code_scanner,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DistributorScanPayScreen()),
                );
              },
            ),
            _buildActionCard('User Ledger', Icons.notes, Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) =>
                        DistributorReportBloc(DistributorRepository()),
                    child: UserLedgerScreen(),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(scrWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.02),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: scrWidth * 0.06),
              ),
              SizedBox(height: scrWidth * 0.02),
              Text(
                title,
                style: TextStyle(
                  fontSize: scrWidth * 0.032,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section Skeleton
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(scrWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: colorConst.primaryColor1.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: scrWidth * 0.08,
                    height: scrWidth * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(scrWidth * 0.01),
                    ),
                  ),
                  SizedBox(width: scrWidth * 0.03),
                  Container(
                    width: scrWidth * 0.3,
                    height: scrWidth * 0.05,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Main Content Skeleton
          Padding(
            padding: EdgeInsets.all(scrWidth * 0.04),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: scrWidth * 0.25,
                    height: scrWidth * 0.05,
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: scrWidth * 0.03),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: scrWidth * 0.03,
                    crossAxisSpacing: scrWidth * 0.03,
                    childAspectRatio: 1.1,
                    children: List.generate(
                      4,
                      (index) => Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(scrWidth * 0.04),
                        child: Column(
                          children: [
                            Container(
                              width: scrWidth * 0.08,
                              height: scrWidth * 0.08,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: scrWidth * 0.02),
                            Container(
                              width: scrWidth * 0.15,
                              height: scrWidth * 0.03,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.03),
                  Container(
                    width: double.infinity,
                    height: scrWidth * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
