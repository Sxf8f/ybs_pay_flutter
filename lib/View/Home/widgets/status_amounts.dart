import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/bloc/dashboardBloc/dashboardBloc.dart';
import '../../../core/bloc/dashboardBloc/dashboardState.dart';
import '../../../main.dart';

/// Constructor for the status containers in the app

class statusAmountsBox extends StatelessWidget {
  const statusAmountsBox({super.key});

  Widget _buildStatBox({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String amount,
    required Color accentColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: scrWidth * 0.01),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(scrWidth * 0.01),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: scrWidth * 0.03,
            horizontal: scrWidth * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.02),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: scrWidth * 0.04,
                  color: accentColor,
                ),
              ),
              SizedBox(height: scrWidth * 0.02),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: scrWidth * 0.025,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: scrWidth * 0.01),
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: scrWidth * 0.029,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonStatBox() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: scrWidth * 0.01),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(scrWidth * 0.01),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: scrWidth * 0.03,
            horizontal: scrWidth * 0.02,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: scrWidth * 0.08,
                  height: scrWidth * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: scrWidth * 0.02),
                Container(
                  width: scrWidth * 0.15,
                  height: scrWidth * 0.025,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: scrWidth * 0.01),
                Container(
                  width: scrWidth * 0.2,
                  height: scrWidth * 0.029,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Padding(
            padding: EdgeInsets.only(
              top: scrWidth * 0.04,
              bottom: scrWidth * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSkeletonStatBox(),
                _buildSkeletonStatBox(),
                _buildSkeletonStatBox(),
                _buildSkeletonStatBox(),
              ],
            ),
          );
        }

        String successAmount = '₹0.00';
        String commissionAmount = '₹0.00';
        String pendingAmount = '₹0.00';
        String failedAmount = '₹0.00';

        if (state is DashboardStatisticsLoaded) {
          successAmount = state.statistics.statistics.success.formatted;
          commissionAmount = state.statistics.statistics.commission.formatted;
          pendingAmount = state.statistics.statistics.pending.formatted;
          failedAmount = state.statistics.statistics.failed.formatted;
        } else if (state is DashboardError) {
          // On error, show default values
          successAmount = '₹0.00';
          commissionAmount = '₹0.00';
          pendingAmount = '₹0.00';
          failedAmount = '₹0.00';
        }

        return Padding(
          padding: EdgeInsets.only(
            top: scrWidth * 0.04,
            bottom: scrWidth * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox(
                context: context,
                icon: Icons.check_circle,
                label: "Success",
                amount: successAmount,
                accentColor: Color(0xFF4CAF50),
              ),
              _buildStatBox(
                context: context,
                icon: Icons.insert_chart_outlined,
                label: "Commission",
                amount: commissionAmount,
                accentColor: Color(0xFF2196F3),
              ),
              _buildStatBox(
                context: context,
                icon: Icons.pending_actions,
                label: "Pending",
                amount: pendingAmount,
                accentColor: Color(0xFFFF9800),
              ),
              _buildStatBox(
                context: context,
                icon: Icons.error_outline,
                label: "Failed",
                amount: failedAmount,
                accentColor: Color(0xFFF44336),
              ),
            ],
          ),
        );
      },
    );
  }
}
