import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/reportsBloc/reportsBloc.dart';
import '../../../core/repository/reportsRepository/reportsRepo.dart';
import '../../../core/bloc/userBloc/userBloc.dart';
import '../../../core/bloc/userBloc/userState.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../screens/reportDetailScreen.dart';
import '../../Distributor/reports/userLedgerScreen.dart';
import '../../Distributor/reports/userDaybookScreen.dart';
import '../../Distributor/reports/fundDebitCreditScreen.dart';
import '../../Distributor/reports/disputeSettlementScreen.dart';
import '../../Distributor/commission/commissionSlabScreen.dart';

/// Constructor for the reports list in the app
class reportsList extends StatefulWidget {
  const reportsList({super.key});

  @override
  State<reportsList> createState() => _reportsListState();
}

class _reportsListState extends State<reportsList> {
  // Retailer reports
  List get retailerReports => [
    {
      'name': 'Recharge Report',
      'icon': Icons.phone_android_outlined,
      'type': 'recharge',
      'color': Color(0xFF607D8B),
      'gradient': [Color(0xFF607D8B), Color(0xFF90A4AE)],
    },
    {
      'name': 'Ledger Report',
      'icon': Icons.notes,
      'type': 'ledger',
      'color': Color(0xFF546E7A),
      'gradient': [Color(0xFF546E7A), Color(0xFF78909C)],
    },
    {
      'name': 'Fund Order Report',
      'icon': Icons.note_alt_outlined,
      'type': 'fund_order',
      'color': Color(0xFF455A64),
      'gradient': [Color(0xFF455A64), Color(0xFF607D8B)],
    },
    {
      'name': 'Complaint Report',
      'icon': Icons.warning_amber_outlined,
      'type': 'complaint',
      'color': Color(0xFF37474F),
      'gradient': [Color(0xFF37474F), Color(0xFF546E7A)],
    },
    {
      'name': 'Fund Debit Credit',
      'icon': Icons.credit_card_rounded,
      'type': 'fund_debit_credit',
      'color': Color(0xFF607D8B),
      'gradient': [Color(0xFF607D8B), Color(0xFF90A4AE)],
    },
    {
      'name': 'User Daybook',
      'icon': Icons.calendar_view_day,
      'type': 'user_daybook',
      'color': Color(0xFF546E7A),
      'gradient': [Color(0xFF546E7A), Color(0xFF78909C)],
    },
    {
      'name': 'Commission Slab',
      'icon': Icons.percent,
      'type': 'commission_slab',
      'color': Color(0xFF455A64),
      'gradient': [Color(0xFF455A64), Color(0xFF607D8B)],
    },
    {
      'name': 'W2R Report',
      'icon': Icons.report_gmailerrorred,
      'type': 'w2r',
      'color': Color(0xFF607D8B),
      'gradient': [Color(0xFF607D8B), Color(0xFF90A4AE)],
    },
  ];

  // Distributor reports
  List get distributorReports => [
    {
      'name': 'Recharge Report',
      'icon': Icons.phone_android_outlined,
      'type': 'recharge',
      'color': Color(0xFF607D8B),
      'gradient': [Color(0xFF607D8B), Color(0xFF90A4AE)],
      'isDistributor': false, // Use retailer report
    },
    {
      'name': 'User Ledger',
      'icon': Icons.notes,
      'type': 'distributor_user_ledger',
      'color': Color(0xFF546E7A),
      'gradient': [Color(0xFF546E7A), Color(0xFF78909C)],
      'isDistributor': true,
    },
    {
      'name': 'User Daybook',
      'icon': Icons.calendar_view_day,
      'type': 'distributor_user_daybook',
      'color': Color(0xFF546E7A),
      'gradient': [Color(0xFF546E7A), Color(0xFF78909C)],
      'isDistributor': true,
    },
    {
      'name': 'Fund Order Report',
      'icon': Icons.note_alt_outlined,
      'type': 'fund_order',
      'color': Color(0xFF455A64),
      'gradient': [Color(0xFF455A64), Color(0xFF607D8B)],
      'isDistributor': false, // Use retailer report
    },
    {
      'name': 'Fund Debit Credit',
      'icon': Icons.credit_card_rounded,
      'type': 'distributor_fund_debit_credit',
      'color': Color(0xFF607D8B),
      'gradient': [Color(0xFF607D8B), Color(0xFF90A4AE)],
      'isDistributor': true,
    },
    {
      'name': 'Dispute Settlement',
      'icon': Icons.gavel,
      'type': 'distributor_dispute_settlement',
      'color': Color(0xFF37474F),
      'gradient': [Color(0xFF37474F), Color(0xFF546E7A)],
      'isDistributor': true,
    },
    {
      'name': 'Commission Slab',
      'icon': Icons.percent,
      'type': 'distributor_commission_slab',
      'color': Color(0xFF455A64),
      'gradient': [Color(0xFF455A64), Color(0xFF607D8B)],
      'isDistributor': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Check if user is distributor
        bool isDistributor = false;
        if (userState is UserLoaded) {
          isDistributor =
              userState.user.roleName.toLowerCase() == 'distributor' ||
              (userState.user.roleId != null && userState.user.roleId == 2);
        }

        // Get appropriate reports list
        final services = isDistributor ? distributorReports : retailerReports;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: scrWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // Header Section (matching home screen style)
              // Container(
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(scrWidth * 0.01),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.1),
              //         blurRadius: 8,
              //         offset: Offset(0, 4),
              //         spreadRadius: 0,
              //       ),
              //     ],
              //   ),
              //   child: Padding(
              //     padding: EdgeInsets.all(scrWidth * 0.04),
              //     child: Row(
              //       children: [
              //         Container(
              //           padding: EdgeInsets.all(scrWidth * 0.02),
              //           decoration: BoxDecoration(
              //             color: colorConst.primaryColor1.withOpacity(0.1),
              //             borderRadius: BorderRadius.circular(scrWidth * 0.01),
              //           ),
              //           child: Icon(
              //             Icons.assessment_outlined,
              //             color: colorConst.primaryColor1,
              //             size: scrWidth * 0.04,
              //           ),
              //         ),
              //         SizedBox(width: scrWidth * 0.03),
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 'Reports',
              //                 style: TextStyle(
              //                   fontWeight: FontWeight.w600,
              //                   color: Colors.black87,
              //                   fontSize: scrWidth * 0.033,
              //                 ),
              //               ),
              //               SizedBox(height: 2),
              //               Text(
              //                 isDistributor
              //                     ? 'View and analyze distributor reports'
              //                     : 'View and analyze your transaction reports',
              //                 style: TextStyle(
              //                   fontSize: scrWidth * 0.025,
              //                   color: Colors.grey[600],
              //                   fontWeight: FontWeight.w400,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(height: scrWidth * 0.1),

              // Grid Layout (matching home screen style)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio:
                      0.70, // Increased height to accommodate longer text like "Commission Slab" and "Fund Debit Credit"
                  crossAxisSpacing: scrWidth * 0.02,
                  mainAxisSpacing: scrWidth * 0.03,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final report = services[index];
                  return _buildReportCard(report, index, isDistributor);
                },
              ),

              SizedBox(height: scrWidth * 0.08),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportCard(
    Map<String, dynamic> report,
    int index,
    bool isDistributor,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _navigateToReport(context, report, isDistributor);
        },
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Container (matching home screen style) - Fixed height for alignment
            SizedBox(
              height: scrWidth * 0.16, // Fixed height for icon row alignment
              width: scrWidth * 0.16, // Fixed width for icon row alignment
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.primary.withOpacity(0.18)
                      : colorConst.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(scrWidth * 0.5),
                  border: Border.all(
                    color: isDark
                        ? scheme.primary.withOpacity(0.35)
                        : colorConst.lightBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  report['icon'],
                  color: colorConst.primaryColor1,
                  size: scrWidth * 0.08,
                ),
              ),
            ),
            SizedBox(height: scrWidth * 0.015),
            // Report Name - Fixed height container for text row alignment
            SizedBox(
              height:
                  scrWidth *
                  0.08, // Increased height to fully display longer text like "Commission Slab" and "Fund Debit Credit"
              child: Center(
                child: Text(
                  report['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: scrWidth * 0.028,
                    height: 1.3, // Increased line height for better spacing
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReport(
    BuildContext context,
    Map<String, dynamic> report,
    bool isDistributor,
  ) {
    final reportType = report['type'] as String;
    final isDistributorReport = report['isDistributor'] == true;

    // Navigate to distributor-specific screens
    if (isDistributor && isDistributorReport) {
      switch (reportType) {
        case 'distributor_user_ledger':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserLedgerScreen()),
          );
          break;
        case 'distributor_user_daybook':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserDaybookScreen()),
          );
          break;
        case 'distributor_fund_debit_credit':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FundDebitCreditScreen()),
          );
          break;
        case 'distributor_dispute_settlement':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DisputeSettlementScreen()),
          );
          break;
        case 'distributor_commission_slab':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CommissionSlabScreen()),
          );
          break;
        default:
          // Fallback to retailer report screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => ReportsBloc(repository: ReportsRepository()),
                child: ReportDetailScreen(
                  reportType: reportType,
                  reportName: report['name'],
                ),
              ),
            ),
          );
      }
    } else {
      // Navigate to retailer report screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ReportsBloc(repository: ReportsRepository()),
            child: ReportDetailScreen(
              reportType: reportType,
              reportName: report['name'],
            ),
          ),
        ),
      );
    }
  }
}
