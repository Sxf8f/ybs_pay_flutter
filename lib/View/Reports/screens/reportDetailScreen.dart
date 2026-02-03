import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../core/bloc/reportsBloc/reportsBloc.dart';
import '../../../core/bloc/reportsBloc/reportsEvent.dart';
import '../../../core/bloc/reportsBloc/reportsState.dart';
import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appState.dart';
import '../../../core/models/reportModels/reportModel.dart';
import '../../../core/const/color_const.dart';
import '../../../core/const/assets_const.dart';
import '../../../core/repository/disputeW2RRepository/disputeW2RRepo.dart';
import '../../widgets/snackBar.dart';
import '../../../main.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportType;
  final String reportName;

  const ReportDetailScreen({
    Key? key,
    required this.reportType,
    required this.reportName,
  }) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _limitController = TextEditingController(
    text: '50',
  );
  bool _isFiltersExpanded = false; // Collapsible filters

  @override
  void initState() {
    super.initState();
    // Set default dates to today
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    // Fetch initial data
    _fetchReport();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _fetchReport() {
    final limit = int.tryParse(_limitController.text) ?? 50;
    final startDateStr = _startDate != null ? _formatDate(_startDate!) : null;
    final endDateStr = _endDate != null ? _formatDate(_endDate!) : null;
    final search = _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim();

    switch (widget.reportType) {
      case 'recharge':
        context.read<ReportsBloc>().add(
          FetchRechargeReport(
            startDate: startDateStr,
            endDate: endDateStr,
            search: search,
            limit: limit,
          ),
        );
        break;
      case 'ledger':
        context.read<ReportsBloc>().add(
          FetchLedgerReport(
            startDate: startDateStr,
            endDate: endDateStr,
            transactionId: search,
            limit: limit,
          ),
        );
        break;
      case 'fund_order':
        context.read<ReportsBloc>().add(
          FetchFundOrderReport(
            fromDate: startDateStr,
            toDate: endDateStr,
            search: search,
            limit: limit,
          ),
        );
        break;
      case 'complaint':
        context.read<ReportsBloc>().add(
          FetchComplaintReport(
            startDate: startDateStr,
            endDate: endDateStr,
            search: search,
            limit: limit,
          ),
        );
        break;
      case 'fund_debit_credit':
        context.read<ReportsBloc>().add(
          FetchFundDebitCreditReport(
            startDate: startDateStr,
            endDate: endDateStr,
            mobile: search,
            limit: limit,
          ),
        );
        break;
      case 'user_daybook':
        context.read<ReportsBloc>().add(
          FetchUserDaybookReport(
            startDate: startDateStr,
            endDate: endDateStr,
            limit: limit,
          ),
        );
        break;
      case 'commission_slab':
        context.read<ReportsBloc>().add(
          FetchCommissionSlabReport(search: search, limit: limit),
        );
        break;
      case 'w2r':
        context.read<ReportsBloc>().add(
          FetchW2RReport(
            startDate: startDateStr,
            endDate: endDateStr,
            transactionId: search,
            limit: limit,
          ),
        );
        break;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: colorConst.primaryColor1,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorConst.primaryColor1,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Back arrow + Logo
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Logo from AppBloc
                      BlocBuilder<AppBloc, AppState>(
                        buildWhen: (previous, current) => current is AppLoaded,
                        builder: (context, state) {
                          String? logoPath;
                          if (state is AppLoaded &&
                              state.settings?.logo != null) {
                            logoPath =
                                "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                          }
                          return Container(
                            height: scrWidth * 0.05,
                            child: logoPath != null && logoPath.isNotEmpty
                                ? Image.network(
                                    logoPath,
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox.shrink();
                                    },
                                  )
                                : SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                  // Right: Empty space (for alignment)
                  SizedBox(width: scrWidth * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Title section below AppBar
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            color: Colors.white,
            child: Center(
              child: Text(
                widget.reportName,
                style: TextStyle(
                  fontSize: scrWidth * 0.042,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          ),
          // Compact Filter Toggle Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_startDate != null ||
                          _endDate != null ||
                          _searchController.text.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorConst.primaryColor1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorConst.primaryColor1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFiltersExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    setState(() {
                      _isFiltersExpanded = !_isFiltersExpanded;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          // Collapsible Filters Section
          if (_isFiltersExpanded)
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.grey[50],
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _startDate != null
                                          ? _formatDate(_startDate!)
                                          : 'Start Date',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _endDate != null
                                          ? _formatDate(_endDate!)
                                          : 'End Date',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: TextStyle(fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: _limitController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Limit',
                              hintStyle: TextStyle(fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _fetchReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorConst.primaryColor1,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            minimumSize: Size(0, 36),
                          ),
                          child: Text('Search', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Report Data Section
          Expanded(
            child: BlocConsumer<ReportsBloc, ReportsState>(
              listener: (context, state) {
                if (state is ReportsError) {
                  showSnack(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return _buildSkeletonLoader();
                }

                if (state is ReportsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return _buildReportContent(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ReportsState state) {
    switch (widget.reportType) {
      case 'recharge':
        if (state is RechargeReportLoaded) {
          return _buildRechargeReport(state.response);
        }
        break;
      case 'ledger':
        if (state is LedgerReportLoaded) {
          return _buildLedgerReport(state.response);
        }
        break;
      case 'fund_order':
        if (state is FundOrderReportLoaded) {
          return _buildFundOrderReport(state.response);
        }
        break;
      case 'complaint':
        if (state is ComplaintReportLoaded) {
          return _buildComplaintReport(state.response);
        }
        break;
      case 'fund_debit_credit':
        if (state is FundDebitCreditReportLoaded) {
          return _buildFundDebitCreditReport(state.response);
        }
        break;
      case 'user_daybook':
        if (state is UserDaybookReportLoaded) {
          return _buildUserDaybookReport(state.response);
        }
        break;
      case 'commission_slab':
        if (state is CommissionSlabReportLoaded) {
          return _buildCommissionSlabReport(state.response);
        }
        break;
      case 'w2r':
        if (state is W2RReportLoaded) {
          return _buildW2RReport(state.response);
        }
        break;
    }

    return Center(child: Text('No data available'));
  }

  Widget _buildRechargeReport(RechargeReportResponse response) {
    if (response.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Build operator image map from filters if available
    Map<String, String> operatorImageMap = {};
    if (response.filters != null && response.filters!['operators'] != null) {
      final operators = response.filters!['operators'] as List;
      for (var op in operators) {
        final operatorName = op['name']?.toString() ?? '';
        final imagePath = op['image']?.toString() ?? '';
        if (operatorName.isNotEmpty && imagePath.isNotEmpty) {
          operatorImageMap[operatorName] = imagePath;
        }
      }
    }

    return Column(
      children: [
        // Professional Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                icon: Icons.receipt_long,
                label: 'Total',
                value: '${response.totalCount}',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildStatChip(
                icon: Icons.visibility,
                label: 'Showing',
                value: '${response.transactions.length}',
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: colorConst.primaryColor1,
                  size: 22,
                ),
                onPressed: () => _generateRechargePDF(response),
                tooltip: 'Download PDF',
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Transaction List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: response.transactions.length,
            itemBuilder: (context, index) {
              final tx = response.transactions[index];
              final operatorImage = operatorImageMap[tx.operatorName] ?? '';
              return _buildRechargeTransactionCard(
                tx,
                operatorImage,
                index == response.transactions.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorConst.primaryColor1),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build operator image box for recharge transaction card
  Widget _buildOperatorImageBox(String operatorImage) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child:
            operatorImage.isNotEmpty &&
                operatorImage != '/' &&
                operatorImage != 'null'
            ? CachedNetworkImage(
                imageUrl: operatorImage.startsWith('http')
                    ? operatorImage
                    : "${AssetsConst.apiBase}${operatorImage.startsWith('/') ? operatorImage.substring(1) : operatorImage}",
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade50,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorConst.primaryColor1,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorConst.primaryColor1.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorConst.primaryColor1,
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                color: colorConst.primaryColor1.withOpacity(0.1),
                child: Center(
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorConst.primaryColor1,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRechargeTransactionCard(
    RechargeTransaction tx,
    String operatorImage,
    bool isLast,
  ) {
    final statusColor = _getStatusColor(tx.statusName);
    final statusBgColor = _getStatusBgColor(tx.statusName);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: false,
          leading: _buildOperatorImageBox(operatorImage),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${tx.amount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      tx.datetime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'TXN: ${tx.transactionId}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tx.liveid != null &&
                        tx.liveid!.isNotEmpty &&
                        tx.liveid != 'null') ...[
                      SizedBox(height: 2),
                      Text(
                        'LIVE: ${tx.liveid}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(tx.statusName, statusColor, statusBgColor),
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          children: [
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 12),
            // Transaction Details
            _buildDetailRow(
              icon: Icons.receipt_outlined,
              label: 'Transaction ID',
              value: tx.transactionId,
              valueStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    icon: Icons.phone_android,
                    label: 'Operator',
                    value: tx.operatorName,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDetailRow(
                    icon: Icons.account_circle_outlined,
                    label: 'Account',
                    value: tx.accountNo,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 10),
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildDetailRow(
            //         icon: Icons.api,
            //         label: 'API',
            //         value: tx.apiName,
            //       ),
            //     ),
            //     SizedBox(width: 16),
            //     if (tx.outlet.isNotEmpty)
            //       Expanded(
            //         child: _buildDetailRow(
            //           icon: Icons.store,
            //           label: 'Outlet',
            //           value: tx.outlet,
            //         ),
            //       ),
            //   ],
            // ),
            if (tx.liveid != null && tx.liveid!.isNotEmpty) ...[
              SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.tag,
                label: 'Live ID',
                value: tx.liveid!,
              ),
            ],
            // Dispute and W2R status/buttons
            // Show for SUCCESS transactions, or for FAILED transactions with dispute/W2R status
            if (tx.statusName.toUpperCase() == 'SUCCESS' ||
                (tx.statusName.toUpperCase() == 'FAILED' &&
                    (tx.disputeRequested == true ||
                        (tx.refundStatus != null &&
                            tx.refundStatus!.isNotEmpty &&
                            tx.refundStatus != 'DISPUTE') ||
                        (tx.w2rStatus != null &&
                            tx.w2rStatus!.isNotEmpty)))) ...[
              SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[200]),
              SizedBox(height: 12),
              // Dispute Status/Button
              if (tx.disputeRequested == true ||
                  (tx.refundStatus != null &&
                      tx.refundStatus!.isNotEmpty &&
                      tx.refundStatus != 'DISPUTE')) ...[
                // Show dispute status badge
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 16,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispute Status',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          _buildStatusBadge(
                            tx.refundStatusDisplay ??
                                _getRefundStatusDisplay(tx.refundStatus),
                            _getRefundStatusColor(tx.refundStatus),
                            _getRefundStatusColor(
                              tx.refundStatus,
                            ).withOpacity(0.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else if (tx.statusName.toUpperCase() == 'SUCCESS') ...[
                // Show dispute button only for SUCCESS transactions
                _buildActionButton(
                  icon: Icons.warning_amber_outlined,
                  label: 'Raise Dispute',
                  color: Colors.orange,
                  onTap: () => _showDisputeDialog(tx),
                ),
              ],
              // W2R Status/Button
              if (tx.w2rAllowed == true) ...[
                if (tx.w2rStatus != null && tx.w2rStatus!.isNotEmpty) ...[
                  // Show W2R status badge
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wrong to Right Status',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            _buildStatusBadge(
                              _getW2RStatusDisplay(tx.w2rStatus),
                              _getW2RStatusColor(tx.w2rStatus),
                              _getW2RStatusColor(tx.w2rStatus).withOpacity(0.1),
                            ),
                            // Show account numbers if W2R is accepted
                            if (tx.w2rStatus?.toUpperCase() == 'ACCEPTED' &&
                                tx.w2rRightAccountNo != null &&
                                tx.w2rRightAccountNo!.isNotEmpty) ...[
                              SizedBox(height: 8),
                              _buildDetailRow(
                                icon: Icons.arrow_downward,
                                label: 'Wrong Account',
                                value: tx.accountNo,
                              ),
                              SizedBox(height: 4),
                              _buildDetailRow(
                                icon: Icons.arrow_upward,
                                label: 'Right Account',
                                value: tx.w2rRightAccountNo!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else if (tx.statusName.toUpperCase() == 'SUCCESS') ...[
                  // Show W2R button only for SUCCESS transactions
                  SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.swap_horiz,
                    label: 'Wrong to Right',
                    color: Colors.blue,
                    onTap: () => _showW2RDialog(tx),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style:
                    valueStyle ??
                    TextStyle(
                      fontSize: 13,
                      color: Colors.grey[900],
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'success' || statusLower == 'completed') {
      return Colors.green;
    } else if (statusLower == 'failed' || statusLower == 'rejected') {
      return Colors.red;
    } else if (statusLower == 'pending' || statusLower == 'processing') {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'success' || statusLower == 'completed') {
      return Colors.green.shade50;
    } else if (statusLower == 'failed' || statusLower == 'rejected') {
      return Colors.red.shade50;
    } else if (statusLower == 'pending' || statusLower == 'processing') {
      return Colors.orange.shade50;
    } else {
      return Colors.grey.shade50;
    }
  }

  Color _getRefundStatusColor(String? status) {
    if (status == null || status.isEmpty) return Colors.grey;
    final statusLower = status.toLowerCase();
    if (statusLower == 'under_review') {
      return Colors.orange;
    } else if (statusLower == 'refunded') {
      return Colors.green;
    } else if (statusLower == 'rejected') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Color _getW2RStatusColor(String? status) {
    if (status == null || status.isEmpty) return Colors.grey;
    final statusLower = status.toLowerCase();
    if (statusLower == 'requested') {
      return Colors.orange;
    } else if (statusLower == 'accepted') {
      return Colors.green;
    } else if (statusLower == 'rejected') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String _getRefundStatusDisplay(String? status) {
    if (status == null || status.isEmpty) return 'Dispute';
    final statusLower = status.toLowerCase();
    if (statusLower == 'under_review') {
      return 'Under Review';
    } else if (statusLower == 'refunded') {
      return 'Refunded';
    } else if (statusLower == 'rejected') {
      return 'Rejected';
    } else {
      return 'Dispute';
    }
  }

  String _getW2RStatusDisplay(String? status) {
    if (status == null || status.isEmpty) return '';
    final statusLower = status.toLowerCase();
    if (statusLower == 'requested') {
      return 'Requested';
    } else if (statusLower == 'accepted') {
      return 'Accepted';
    } else if (statusLower == 'rejected') {
      return 'Rejected';
    } else {
      return '';
    }
  }

  Widget _buildLedgerReport(LedgerReportResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No ledger entries found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate opening and closing balance
    // Opening balance = last entry's balance before that transaction
    // Closing balance = first entry's balance (most recent)
    double openingBalance = 0.0;
    double closingBalance = 0.0;

    if (response.data.isNotEmpty) {
      final lastEntry = response.data.last;
      closingBalance = lastEntry.balanceAfter;
      // Opening balance = balance after - amount (reverse the transaction)
      openingBalance = lastEntry.balanceAfter - lastEntry.amount;

      // If we have the first entry (most recent), use its balance as closing
      final firstEntry = response.data.first;
      closingBalance = firstEntry.balanceAfter;
    }

    return Column(
      children: [
        // Compact Bank Statement Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Statement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${_startDate != null ? _formatDate(_startDate!) : "N/A"} - ${_endDate != null ? _formatDate(_endDate!) : "N/A"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: colorConst.primaryColor1,
                      size: 22,
                    ),
                    onPressed: () => _generateLedgerPDF(
                      response,
                      openingBalance,
                      closingBalance,
                    ),
                    tooltip: 'Download PDF',
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Compact Summary Row
              Row(
                children: [
                  Expanded(
                    child: _buildCompactBalanceCard(
                      'Opening',
                      openingBalance,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactBalanceCard(
                      'Closing',
                      closingBalance,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactBalanceCard(
                      'Transactions',
                      response.returnedCount.toDouble(),
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Statement Table Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Date & Time',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Transaction ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Balance',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Statement Entries
        Expanded(
          child: ListView.builder(
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final entry = response.data[index];
              final isCredit =
                  entry.transactionType.toLowerCase() == 'credit' ||
                  entry.amount >= 0;
              return _buildBankStatementRow(
                entry,
                isCredit,
                index == response.data.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBalanceCard(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            label.toLowerCase().contains('transaction')
                ? value.toInt().toString()
                : 'Rs.${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String label, double value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label.contains('Transactions')
                  ? value.toInt().toString()
                  : 'Rs.${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankStatementRow(
    LedgerTransaction entry,
    bool isCredit,
    bool isLast,
  ) {
    final dateTimeFormatted = entry.dateTimeFormatted;
    final displayDate = dateTimeFormatted != null
        ? '${dateTimeFormatted['date'] ?? ''}\n${dateTimeFormatted['time'] ?? ''}'
        : entry.dateTime;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: InkWell(
        onTap: () {
          _showTransactionDetailsDialog(entry, isCredit);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  displayDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.transactionName.isNotEmpty
                          ? entry.transactionName
                          : entry.description,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.remark.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        entry.remark,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  entry.transactionId.length > 12
                      ? '${entry.transactionId.substring(0, 12)}...'
                      : entry.transactionId,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  isCredit
                      ? '+Rs.${entry.amount.abs().toStringAsFixed(2)}'
                      : '-Rs.${entry.amount.abs().toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rs.${entry.balanceAfter.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetailsDialog(LedgerTransaction entry, bool isCredit) {
    final dateTimeFormatted = entry.dateTimeFormatted;
    final displayDate = dateTimeFormatted != null
        ? '${dateTimeFormatted['date'] ?? ''} ${dateTimeFormatted['time'] ?? ''}'
        : entry.dateTime;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxWidth: scrWidth * 0.9),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 16),

                // Transaction ID
                _buildDetailItem(
                  'Transaction ID',
                  entry.transactionId,
                  Icons.receipt_long,
                ),
                SizedBox(height: 12),

                // Date & Time
                _buildDetailItem('Date & Time', displayDate, Icons.access_time),
                SizedBox(height: 12),

                // Description
                _buildDetailItem(
                  'Description',
                  entry.transactionName.isNotEmpty
                      ? entry.transactionName
                      : entry.description,
                  Icons.description,
                  maxLines: 3,
                ),
                SizedBox(height: 12),

                // Transaction Type
                _buildDetailItem(
                  'Transaction Type',
                  entry.transactionType.toUpperCase(),
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  valueColor: isCredit ? Colors.green : Colors.red,
                ),
                SizedBox(height: 12),

                // Amount
                _buildDetailItem(
                  'Amount',
                  isCredit
                      ? '+Rs.${entry.amount.abs().toStringAsFixed(2)}'
                      : '-Rs.${entry.amount.abs().toStringAsFixed(2)}',
                  Icons.currency_rupee,
                  valueColor: isCredit ? Colors.green : Colors.red,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),

                // Old Balance
                _buildDetailItem(
                  'Opening Balance',
                  'Rs.${entry.oldBalance}',
                  Icons.account_balance_wallet,
                ),
                SizedBox(height: 12),

                // Balance After
                _buildDetailItem(
                  'Closing Balance',
                  'Rs.${entry.balanceAfter.toStringAsFixed(2)}',
                  Icons.account_balance,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[900],
                  ),
                ),

                // Credit/Debit Details
                if (double.parse(entry.credit) > 0 ||
                    double.parse(entry.debit) > 0) ...[
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                  if (double.parse(entry.credit) > 0)
                    _buildDetailItem(
                      'Credit',
                      'Rs.${entry.credit}',
                      Icons.add_circle,
                      valueColor: Colors.green,
                    ),
                  if (double.parse(entry.debit) > 0) ...[
                    if (double.parse(entry.credit) > 0) SizedBox(height: 8),
                    _buildDetailItem(
                      'Debit',
                      'Rs.${entry.debit}',
                      Icons.remove_circle,
                      valueColor: Colors.red,
                    ),
                  ],
                ],

                // Remark
                if (entry.remark.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                  _buildDetailItem(
                    'Remarks',
                    entry.remark,
                    Icons.note,
                    maxLines: 3,
                  ),
                ],

                // User Info (if available)
                if (entry.user != null) ...[
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                  if (entry.user!['username'] != null)
                    _buildDetailItem(
                      'User',
                      entry.user!['username'].toString(),
                      Icons.person,
                    ),
                  if (entry.user!['phone_number'] != null) ...[
                    SizedBox(height: 8),
                    _buildDetailItem(
                      'Phone',
                      entry.user!['phone_number'].toString(),
                      Icons.phone,
                    ),
                  ],
                ],

                SizedBox(height: 20),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    TextStyle? valueStyle,
    int maxLines = 1,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style:
                    valueStyle ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.grey[900],
                      fontFamily: isMonospace ? 'monospace' : null,
                    ),
                maxLines: maxLines,
                overflow: maxLines > 1
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFundOrderReport(FundOrderReportResponse response) {
    if (response.data.isEmpty) {
      return Center(child: Text('No fund orders found'));
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: ${response.count}'),
              Text('Showing: ${response.returnedCount}'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final order = response.data[index];
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('₹${order.amount}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TXN: ${order.transactionId}'),
                      Text('${order.accountHolder} - ${order.bank}'),
                      Text('Status: ${order.statusName}'),
                      Text('Mode: ${order.transferModeName}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintReport(ComplaintReportResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No complaints found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Compact Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                icon: Icons.report_problem,
                label: 'Total',
                value: '${response.count}',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildStatChip(
                icon: Icons.visibility,
                label: 'Showing',
                value: '${response.returnedCount}',
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: colorConst.primaryColor1,
                  size: 22,
                ),
                onPressed: () => _generateComplaintPDF(response),
                tooltip: 'Download PDF',
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Complaint List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final complaint = response.data[index];
              return _buildComplaintCard(
                complaint,
                index == response.data.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintCard(ComplaintTransaction complaint, bool isLast) {
    final refundStatusColor = _getRefundStatusColor(
      complaint.refundStatus.isEmpty ? null : complaint.refundStatus,
    );
    final statusColor = _getStatusColor(complaint.status);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showComplaintDetailsDialog(complaint),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs.${complaint.amount}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          complaint.transactionId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(
                        complaint.refundStatusDisplay,
                        refundStatusColor,
                        refundStatusColor.withOpacity(0.1),
                      ),
                      SizedBox(height: 6),
                      _buildStatusBadge(
                        complaint.status,
                        statusColor,
                        statusColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey[200]),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.phone_android,
                      'Operator',
                      complaint.operator,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.account_balance_wallet,
                      'Account',
                      complaint.accountNo,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      'Request Date',
                      complaint.requestDate,
                    ),
                  ),
                  if (complaint.acceptRejectDate != null) ...[
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.check_circle_outline,
                        'Resolved',
                        complaint.acceptRejectDate!,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDetailsDialog(ComplaintTransaction complaint) {
    final refundStatusColor = _getRefundStatusColor(
      complaint.refundStatus.isEmpty ? null : complaint.refundStatus,
    );
    final statusColor = _getStatusColor(complaint.status);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxWidth: scrWidth * 0.9),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Complaint Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 16),
                _buildDetailItem(
                  'Transaction ID',
                  complaint.transactionId,
                  Icons.receipt_long,
                  isMonospace: true,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Amount',
                  'Rs.${complaint.amount}',
                  Icons.currency_rupee,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Operator',
                  complaint.operator,
                  Icons.phone_android,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Account Number',
                  complaint.accountNo,
                  Icons.account_balance_wallet,
                ),
                SizedBox(height: 12),
                _buildDetailItem('API', complaint.api, Icons.api),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Recharge Date',
                  complaint.rechargeDate,
                  Icons.calendar_today,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Request Date',
                  complaint.requestDate,
                  Icons.schedule,
                ),
                if (complaint.acceptRejectDate != null) ...[
                  SizedBox(height: 12),
                  _buildDetailItem(
                    'Resolved Date',
                    complaint.acceptRejectDate!,
                    Icons.check_circle,
                  ),
                ],
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Status',
                  complaint.status,
                  Icons.info_outline,
                  valueColor: statusColor,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Refund Status',
                  complaint.refundStatusDisplay,
                  Icons.refresh,
                  valueColor: refundStatusColor,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFundDebitCreditReport(FundDebitCreditReportResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate opening and closing balance
    double openingBalance = 0.0;
    double closingBalance = 0.0;

    if (response.data.isNotEmpty) {
      final lastEntry = response.data.last;
      closingBalance = lastEntry.balanceAfter;
      openingBalance = lastEntry.balanceAfter - lastEntry.amount;

      final firstEntry = response.data.first;
      closingBalance = firstEntry.balanceAfter;
    }

    return Column(
      children: [
        // Compact Fund Debit/Credit Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fund Debit/Credit Statement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${_startDate != null ? _formatDate(_startDate!) : "N/A"} - ${_endDate != null ? _formatDate(_endDate!) : "N/A"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: colorConst.primaryColor1,
                      size: 22,
                    ),
                    onPressed: () => _generateFundDebitCreditPDF(response),
                    tooltip: 'Download PDF',
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Compact Summary Row
              Row(
                children: [
                  Expanded(
                    child: _buildCompactBalanceCard(
                      'Opening',
                      openingBalance,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactBalanceCard(
                      'Closing',
                      closingBalance,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactBalanceCard(
                      'Transactions',
                      response.returnedCount.toDouble(),
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Statement Table Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Date & Time',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Transaction ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Balance',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Statement Entries
        Expanded(
          child: ListView.builder(
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final tx = response.data[index];
              final isCredit =
                  tx.transactionType.toLowerCase() == 'credit' ||
                  tx.amount >= 0;
              return _buildFundDebitCreditRow(
                tx,
                isCredit,
                index == response.data.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFundDebitCreditRow(
    FundDebitCreditTransaction tx,
    bool isCredit,
    bool isLast,
  ) {
    final displayDate = tx.datetime.isNotEmpty ? tx.datetime : tx.entryDate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: InkWell(
        onTap: () {
          _showFundDebitCreditDetailsDialog(tx, isCredit);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  displayDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.transactionName.isNotEmpty
                          ? tx.transactionName
                          : tx.description,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tx.service.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        tx.service,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  tx.transactionId.length > 12
                      ? '${tx.transactionId.substring(0, 12)}...'
                      : tx.transactionId,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  isCredit
                      ? '+Rs.${tx.amount.abs().toStringAsFixed(2)}'
                      : '-Rs.${tx.amount.abs().toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rs.${tx.balanceAfter.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFundDebitCreditDetailsDialog(
    FundDebitCreditTransaction tx,
    bool isCredit,
  ) {
    final displayDate = tx.datetime.isNotEmpty ? tx.datetime : tx.entryDate;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxWidth: scrWidth * 0.9),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 16),

                // Transaction ID
                _buildDetailItem(
                  'Transaction ID',
                  tx.transactionId,
                  Icons.receipt_long,
                ),
                SizedBox(height: 12),

                // Date & Time
                _buildDetailItem('Date & Time', displayDate, Icons.access_time),
                SizedBox(height: 12),

                // Description
                _buildDetailItem(
                  'Description',
                  tx.transactionName.isNotEmpty
                      ? tx.transactionName
                      : tx.description,
                  Icons.description,
                  maxLines: 3,
                ),
                SizedBox(height: 12),

                // Service
                if (tx.service.isNotEmpty) ...[
                  _buildDetailItem('Service', tx.service, Icons.business),
                  SizedBox(height: 12),
                ],

                // Transaction Type
                _buildDetailItem(
                  'Transaction Type',
                  tx.transactionType.toUpperCase(),
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  valueColor: isCredit ? Colors.green : Colors.red,
                ),
                SizedBox(height: 12),

                // Amount
                _buildDetailItem(
                  'Amount',
                  isCredit
                      ? '+Rs.${tx.amount.abs().toStringAsFixed(2)}'
                      : '-Rs.${tx.amount.abs().toStringAsFixed(2)}',
                  Icons.currency_rupee,
                  valueColor: isCredit ? Colors.green : Colors.red,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),

                // Balance After
                _buildDetailItem(
                  'Balance After',
                  'Rs.${tx.balanceAfter.toStringAsFixed(2)}',
                  Icons.account_balance,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 12),

                // Wallet Type
                _buildDetailItem(
                  'Wallet Type',
                  tx.walletTypeName,
                  Icons.account_balance_wallet,
                ),

                // Mobile
                if (tx.mobile.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _buildDetailItem('Mobile', tx.mobile, Icons.phone),
                ],

                // Remark
                if (tx.remark.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                  _buildDetailItem(
                    'Remarks',
                    tx.remark,
                    Icons.note,
                    maxLines: 3,
                  ),
                ],

                SizedBox(height: 20),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDaybookReport(UserDaybookReportResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No daybook entries found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Compact Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                icon: Icons.book,
                label: 'Total',
                value: '${response.count}',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildStatChip(
                icon: Icons.visibility,
                label: 'Showing',
                value: '${response.returnedCount}',
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: colorConst.primaryColor1,
                  size: 22,
                ),
                onPressed: () => _generateUserDaybookPDF(response),
                tooltip: 'Download PDF',
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Daybook List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final entry = response.data[index];
              return _buildDaybookCard(
                entry,
                index == response.data.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaybookCard(UserDaybookEntry entry, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: false,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorConst.primaryColor1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.book, color: colorConst.primaryColor1, size: 20),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.operatorName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: 4),
              Text(
                entry.apiName,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              entry.dateTime,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs.${entry.totalAmount}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${entry.totalHits} hits',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          children: [
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 12),
            // Summary Grid
            Row(
              children: [
                Expanded(
                  child: _buildDaybookStatBox(
                    'Total',
                    '${entry.totalHits}',
                    'Rs.${entry.totalAmount}',
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildDaybookStatBox(
                    'Success',
                    '${entry.successHits}',
                    'Rs.${entry.successAmount}',
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDaybookStatBox(
                    'Failed',
                    '${entry.failedHits}',
                    'Rs.${entry.failedAmount}',
                    Colors.red,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildDaybookStatBox(
                    'Pending',
                    '${entry.pendingHits}',
                    'Rs.${entry.pendingAmount}',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDaybookStatBox(
                    'Commission',
                    '',
                    'Rs.${entry.directCommission}',
                    Colors.purple,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildDaybookStatBox(
                    'Incentive',
                    '',
                    'Rs.${entry.directIncentive}',
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaybookStatBox(
    String label,
    String hits,
    String amount,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          if (hits.isNotEmpty)
            Text(
              hits,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionSlabReport(CommissionSlabReportResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No commission slabs found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Compact Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                icon: Icons.account_tree,
                label: 'Total',
                value: '${response.count}',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildStatChip(
                icon: Icons.visibility,
                label: 'Showing',
                value: '${response.returnedCount}',
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: colorConst.primaryColor1,
                  size: 22,
                ),
                onPressed: () => _generateCommissionSlabPDF(response),
                tooltip: 'Download PDF',
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Commission Slab List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final slab = response.data[index];
              return _buildCommissionSlabCard(
                slab,
                index == response.data.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionSlabCard(CommissionSlab slab, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Operator Icon
            _buildOperatorIcon(slab.operatorIcon),
            SizedBox(width: 12),
            // Operator Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slab.operatorName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          slab.operatorType,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ID: ${slab.commissionId}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Commission Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Commission',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rs.${slab.rt}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorConst.primaryColor1,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build operator icon widget
  Widget _buildOperatorIcon(String? operatorIcon) {
    final iconSize = scrWidth * 0.12;

    if (operatorIcon != null && operatorIcon.isNotEmpty) {
      return Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: _buildImageUrl(operatorIcon),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade100,
              child: Center(
                child: SizedBox(
                  width: iconSize * 0.4,
                  height: iconSize * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorConst.primaryColor1,
                    ),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.business,
                color: Colors.grey.shade400,
                size: iconSize * 0.5,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: Icon(
          Icons.business,
          color: Colors.grey.shade400,
          size: iconSize * 0.5,
        ),
      );
    }
  }

  /// Build the full image URL from operator icon path
  String _buildImageUrl(String operatorIcon) {
    // If the icon already starts with http, return as is
    if (operatorIcon.startsWith('http://') ||
        operatorIcon.startsWith('https://')) {
      return operatorIcon;
    }

    // Remove leading slash if present to avoid double slashes
    String cleanPath = operatorIcon.startsWith('/')
        ? operatorIcon.substring(1)
        : operatorIcon;

    // Combine with base URL
    String baseUrl = AssetsConst.apiBase.endsWith('/')
        ? AssetsConst.apiBase.substring(0, AssetsConst.apiBase.length - 1)
        : AssetsConst.apiBase;

    return '$baseUrl/$cleanPath';
  }

  Widget _buildW2RReport(W2RReportResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No W2R requests found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Compact Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                icon: Icons.swap_horiz,
                label: 'Total',
                value: '${response.count}',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildStatChip(
                icon: Icons.visibility,
                label: 'Showing',
                value: '${response.returnedCount}',
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: colorConst.primaryColor1,
                  size: 22,
                ),
                onPressed: () => _generateW2RPDF(response),
                tooltip: 'Download PDF',
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // W2R List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final w2r = response.data[index];
              return _buildW2RCard(w2r, index == response.data.length - 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildW2RCard(W2RTransaction w2r, bool isLast) {
    Color statusColor = Colors.orange;
    if (w2r.status == 'ACCEPTED') statusColor = Colors.green;
    if (w2r.status == 'REJECTED') statusColor = Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showW2RDetailsDialog(w2r),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction ID',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          w2r.transactionId,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[900],
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(
                    w2r.statusDisplay,
                    statusColor,
                    statusColor.withOpacity(0.1),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAccountTransferItem(
                      Icons.arrow_downward,
                      'From',
                      w2r.originalAccountNo,
                      Colors.red,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildAccountTransferItem(
                      Icons.arrow_upward,
                      'To',
                      w2r.rightAccountNo,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              if (w2r.remarks.isNotEmpty) ...[
                SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[200]),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remarks',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            w2r.remarks,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTransferItem(
    IconData icon,
    String label,
    String account,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            account,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showW2RDetailsDialog(W2RTransaction w2r) {
    Color statusColor = Colors.orange;
    if (w2r.status == 'ACCEPTED') statusColor = Colors.green;
    if (w2r.status == 'REJECTED') statusColor = Colors.red;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxWidth: scrWidth * 0.9),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'W2R Request Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 16),
                _buildDetailItem(
                  'Transaction ID',
                  w2r.transactionId,
                  Icons.receipt_long,
                  isMonospace: true,
                ),
                if (w2r.adminTransactionId.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _buildDetailItem(
                    'Admin TXN ID',
                    w2r.adminTransactionId,
                    Icons.admin_panel_settings,
                    isMonospace: true,
                  ),
                ],
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                _buildDetailItem(
                  'From Account',
                  w2r.originalAccountNo,
                  Icons.arrow_downward,
                  valueColor: Colors.red,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  'To Account',
                  w2r.rightAccountNo,
                  Icons.arrow_upward,
                  valueColor: Colors.green,
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Status',
                  w2r.statusDisplay,
                  Icons.info_outline,
                  valueColor: statusColor,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  'Created At',
                  w2r.createdAt,
                  Icons.calendar_today,
                ),
                SizedBox(height: 12),
                _buildDetailItem('Updated At', w2r.updatedAt, Icons.update),
                if (w2r.statusUpdatedAt != null) ...[
                  SizedBox(height: 12),
                  _buildDetailItem(
                    'Status Updated',
                    w2r.statusUpdatedAt!,
                    Icons.check_circle,
                  ),
                ],
                if (w2r.remarks.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                  _buildDetailItem(
                    'Remarks',
                    w2r.remarks,
                    Icons.note,
                    maxLines: 3,
                  ),
                ],
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value1,
    String value2, [
    Color? color,
  ]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              if (value1.isNotEmpty) ...[
                Text(value1, style: TextStyle(color: color)),
                SizedBox(width: 8),
              ],
              Text(
                value2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDisputeDialog(RechargeTransaction tx) async {
    final remarksController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Raise Dispute'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID: ${tx.transactionId}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Amount: ₹${tx.amount}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        labelText: 'Remarks (Optional)',
                        hintText: 'Enter remarks about the dispute',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          try {
                            final repository = DisputeW2RRepository();
                            final response = await repository.createDispute(
                              transactionId: tx.transactionId,
                              remarks: remarksController.text.trim().isEmpty
                                  ? null
                                  : remarksController.text.trim(),
                            );
                            Navigator.of(dialogContext).pop();
                            showSnack(context, response.message);
                            // Refresh the report
                            _fetchReport();
                          } catch (e) {
                            setState(() => isLoading = false);
                            showSnack(
                              context,
                              e.toString().replaceAll('Exception: ', ''),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showW2RDialog(RechargeTransaction tx) async {
    final rightAccountController = TextEditingController();
    final remarksController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Wrong to Right'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID: ${tx.transactionId}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Current Account: ${tx.accountNo}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Amount: ₹${tx.amount}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: rightAccountController,
                      decoration: InputDecoration(
                        labelText: 'Correct Account Number *',
                        hintText: 'Enter the correct account number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        labelText: 'Remarks (Optional)',
                        hintText: 'Enter remarks about the correction',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (rightAccountController.text.trim().isEmpty) {
                            showSnack(
                              context,
                              'Please enter the correct account number',
                            );
                            return;
                          }
                          setState(() => isLoading = true);
                          try {
                            final repository = DisputeW2RRepository();
                            final response = await repository.createW2R(
                              transactionId: tx.transactionId,
                              rightAccountNo: rightAccountController.text
                                  .trim(),
                              remarks: remarksController.text.trim().isEmpty
                                  ? null
                                  : remarksController.text.trim(),
                            );
                            Navigator.of(dialogContext).pop();
                            showSnack(context, response.message);
                            // Refresh the report
                            _fetchReport();
                          } catch (e) {
                            setState(() => isLoading = false);
                            showSnack(
                              context,
                              e.toString().replaceAll('Exception: ', ''),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== PDF Generation Methods ====================

  Future<pw.ImageProvider?> _loadLogoImage() async {
    try {
      final appState = context.read<AppBloc>().state;
      String? logoUrl;
      if (appState is AppLoaded && appState.settings?.logo != null) {
        logoUrl =
            "${AssetsConst.apiBase}media/${appState.settings!.logo!.image}";
      }

      if (logoUrl != null && logoUrl.startsWith('http')) {
        try {
          final logoResponse = await http.get(Uri.parse(logoUrl));
          if (logoResponse.statusCode == 200) {
            final logoBytes = logoResponse.bodyBytes;
            return pw.MemoryImage(logoBytes);
          }
        } catch (e) {
          print('Error loading logo: $e');
        }
      }
    } catch (e) {
      print('Error getting logo: $e');
    }
    return null;
  }

  String _getFilterInfo() {
    List<String> filters = [];
    if (_startDate != null) {
      filters.add('Start Date: ${_formatDate(_startDate!)}');
    }
    if (_endDate != null) {
      filters.add('End Date: ${_formatDate(_endDate!)}');
    }
    if (_searchController.text.isNotEmpty) {
      filters.add('Search: ${_searchController.text}');
    }
    if (_limitController.text.isNotEmpty) {
      filters.add('Limit: ${_limitController.text}');
    }
    return filters.isEmpty ? 'No filters applied' : filters.join(' | ');
  }

  Future<void> _generateRechargePDF(RechargeReportResponse response) async {
    try {
      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Logo Header (Centered)
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(logoImage, height: 40, fit: pw.BoxFit.contain),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  widget.reportName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  _getFilterInfo(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPDFStatBox('Total', response.totalCount.toString()),
                  _buildPDFStatBox('Showing', response.transactions.length.toString()),
                ],
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPDFCell('Date & Time', isHeader: true),
                      _buildPDFCell('Transaction ID', isHeader: true),
                      _buildPDFCell('Amount', isHeader: true, align: pw.TextAlign.right),
                      _buildPDFCell('Operator', isHeader: true),
                      _buildPDFCell('Account', isHeader: true),
                      _buildPDFCell('Status', isHeader: true),
                    ],
                  ),
                  ...response.transactions.map((tx) {
                    return pw.TableRow(
                      children: [
                        _buildPDFCell(tx.datetime, fontSize: 9),
                        _buildPDFCell(tx.transactionId, fontSize: 8),
                        _buildPDFCell('Rs.${tx.amount}', fontSize: 9, align: pw.TextAlign.right),
                        _buildPDFCell(tx.operatorName, fontSize: 9),
                        _buildPDFCell(tx.accountNo, fontSize: 9),
                        _buildPDFCell(tx.statusName, fontSize: 9),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await _saveAndSharePDF(pdf, 'recharge_report');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

  Future<void> _generateLedgerPDF(
    LedgerReportResponse response,
    double openingBalance,
    double closingBalance,
  ) async {
    try {
      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Logo Header
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(logoImage, height: 40, fit: pw.BoxFit.contain),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  'Account Statement',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  _getFilterInfo(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPDFStatBox('Opening Balance', 'Rs.${openingBalance.toStringAsFixed(2)}'),
                  _buildPDFStatBox('Closing Balance', 'Rs.${closingBalance.toStringAsFixed(2)}'),
                  _buildPDFStatBox('Transactions', response.returnedCount.toString()),
                ],
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPDFCell('Date & Time', isHeader: true),
                      _buildPDFCell('Description', isHeader: true),
                      _buildPDFCell('Transaction ID', isHeader: true),
                      _buildPDFCell('Amount', isHeader: true, align: pw.TextAlign.right),
                      _buildPDFCell('Balance', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  ...response.data.map((entry) {
                    final isCredit = entry.transactionType.toLowerCase() == 'credit' || entry.amount >= 0;
                    final dateTimeFormatted = entry.dateTimeFormatted;
                    final displayDate = dateTimeFormatted != null
                        ? '${dateTimeFormatted['date'] ?? ''} ${dateTimeFormatted['time'] ?? ''}'
                        : entry.dateTime;

                    return pw.TableRow(
                      children: [
                        _buildPDFCell(displayDate, fontSize: 9),
                        _buildPDFCell(
                          entry.transactionName.isNotEmpty ? entry.transactionName : entry.description,
                          fontSize: 9,
                          maxLines: 2,
                        ),
                        _buildPDFCell(entry.transactionId, fontSize: 8),
                        _buildPDFCell(
                          isCredit
                              ? '+Rs.${entry.amount.abs().toStringAsFixed(2)}'
                              : '-Rs.${entry.amount.abs().toStringAsFixed(2)}',
                          fontSize: 9,
                          align: pw.TextAlign.right,
                        ),
                        _buildPDFCell(
                          'Rs.${entry.balanceAfter.toStringAsFixed(2)}',
                          fontSize: 9,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await _saveAndSharePDF(pdf, 'ledger_statement');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

  Future<void> _generateComplaintPDF(ComplaintReportResponse response) async {
    try {
      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(logoImage, height: 40, fit: pw.BoxFit.contain),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  widget.reportName,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  _getFilterInfo(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPDFStatBox('Total', response.count.toString()),
                  _buildPDFStatBox('Showing', response.returnedCount.toString()),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPDFCell('Transaction ID', isHeader: true),
                      _buildPDFCell('Amount', isHeader: true, align: pw.TextAlign.right),
                      _buildPDFCell('Operator', isHeader: true),
                      _buildPDFCell('Account', isHeader: true),
                      _buildPDFCell('Status', isHeader: true),
                      _buildPDFCell('Refund Status', isHeader: true),
                    ],
                  ),
                  ...response.data.map((complaint) {
                    return pw.TableRow(
                      children: [
                        _buildPDFCell(complaint.transactionId, fontSize: 8),
                        _buildPDFCell('Rs.${complaint.amount}', fontSize: 9, align: pw.TextAlign.right),
                        _buildPDFCell(complaint.operator, fontSize: 9),
                        _buildPDFCell(complaint.accountNo, fontSize: 9),
                        _buildPDFCell(complaint.status, fontSize: 9),
                        _buildPDFCell(complaint.refundStatusDisplay, fontSize: 9),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await _saveAndSharePDF(pdf, 'complaint_report');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

  Future<void> _generateFundDebitCreditPDF(FundDebitCreditReportResponse response) async {
    try {
      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      double openingBalance = 0.0;
      double closingBalance = 0.0;
      if (response.data.isNotEmpty) {
        final lastEntry = response.data.last;
        openingBalance = lastEntry.balanceAfter - lastEntry.amount;
        final firstEntry = response.data.first;
        closingBalance = firstEntry.balanceAfter;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(logoImage, height: 40, fit: pw.BoxFit.contain),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Fund Debit/Credit Statement',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  _getFilterInfo(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPDFStatBox('Opening Balance', 'Rs.${openingBalance.toStringAsFixed(2)}'),
                  _buildPDFStatBox('Closing Balance', 'Rs.${closingBalance.toStringAsFixed(2)}'),
                  _buildPDFStatBox('Transactions', response.returnedCount.toString()),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPDFCell('Date & Time', isHeader: true),
                      _buildPDFCell('Description', isHeader: true),
                      _buildPDFCell('Transaction ID', isHeader: true),
                      _buildPDFCell('Amount', isHeader: true, align: pw.TextAlign.right),
                      _buildPDFCell('Balance', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  ...response.data.map((tx) {
                    final isCredit = tx.transactionType.toLowerCase() == 'credit' || tx.amount >= 0;
                    final displayDate = tx.datetime.isNotEmpty ? tx.datetime : tx.entryDate;

                    return pw.TableRow(
                      children: [
                        _buildPDFCell(displayDate, fontSize: 9),
                        _buildPDFCell(
                          tx.transactionName.isNotEmpty ? tx.transactionName : tx.description,
                          fontSize: 9,
                          maxLines: 2,
                        ),
                        _buildPDFCell(tx.transactionId, fontSize: 8),
                        _buildPDFCell(
                          isCredit
                              ? '+Rs.${tx.amount.abs().toStringAsFixed(2)}'
                              : '-Rs.${tx.amount.abs().toStringAsFixed(2)}',
                          fontSize: 9,
                          align: pw.TextAlign.right,
                        ),
                        _buildPDFCell(
                          'Rs.${tx.balanceAfter.toStringAsFixed(2)}',
                          fontSize: 9,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await _saveAndSharePDF(pdf, 'fund_debit_credit_statement');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

  Future<void> _generateUserDaybookPDF(UserDaybookReportResponse response) async {
    try {
      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(logoImage, height: 40, fit: pw.BoxFit.contain),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  widget.reportName,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  _getFilterInfo(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPDFStatBox('Total', response.count.toString()),
                  _buildPDFStatBox('Showing', response.returnedCount.toString()),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPDFCell('Date & Time', isHeader: true),
                      _buildPDFCell('Operator', isHeader: true),
                      _buildPDFCell('API', isHeader: true),
                      _buildPDFCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
                      _buildPDFCell('Total Hits', isHeader: true, align: pw.TextAlign.right),
                      _buildPDFCell('Success Hits', isHeader: true, align: pw.TextAlign.right),
                      _buildPDFCell('Failed Hits', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  ...response.data.map((entry) {
                    return pw.TableRow(
                      children: [
                        _buildPDFCell(entry.dateTime, fontSize: 9),
                        _buildPDFCell(entry.operatorName, fontSize: 9),
                        _buildPDFCell(entry.apiName, fontSize: 9),
                        _buildPDFCell('Rs.${entry.totalAmount}', fontSize: 9, align: pw.TextAlign.right),
                        _buildPDFCell(entry.totalHits.toString(), fontSize: 9, align: pw.TextAlign.right),
                        _buildPDFCell(entry.successHits.toString(), fontSize: 9, align: pw.TextAlign.right),
                        _buildPDFCell(entry.failedHits.toString(), fontSize: 9, align: pw.TextAlign.right),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await _saveAndSharePDF(pdf, 'user_daybook_report');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

  Future<void> _generateCommissionSlabPDF(CommissionSlabReportResponse response) async {
    try {
      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(logoImage, height: 40, fit: pw.BoxFit.contain),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  widget.reportName,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  _getFilterInfo(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPDFStatBox('Total', response.count.toString()),
                  _buildPDFStatBox('Showing', response.returnedCount.toString()),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPDFCell('Operator', isHeader: true),
                      _buildPDFCell('Type', isHeader: true),
                      _buildPDFCell('Commission ID', isHeader: true),
                      _buildPDFCell('Commission', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  ...response.data.map((slab) {
                    return pw.TableRow(
                      children: [
                        _buildPDFCell(slab.operatorName, fontSize: 9),
                        _buildPDFCell(slab.operatorType, fontSize: 9),
                        _buildPDFCell(slab.commissionId.toString(), fontSize: 8),
                        _buildPDFCell('Rs.${slab.rt}', fontSize: 9, align: pw.TextAlign.right),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await _saveAndSharePDF(pdf, 'commission_slab_report');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

  Future<void> _generateW2RPDF(W2RReportResponse response) async {
    try {
      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(logoImage, height: 40, fit: pw.BoxFit.contain),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  widget.reportName,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  _getFilterInfo(),
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPDFStatBox('Total', response.count.toString()),
                  _buildPDFStatBox('Showing', response.returnedCount.toString()),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPDFCell('Transaction ID', isHeader: true),
                      _buildPDFCell('From Account', isHeader: true),
                      _buildPDFCell('To Account', isHeader: true),
                      _buildPDFCell('Status', isHeader: true),
                      _buildPDFCell('Created At', isHeader: true),
                    ],
                  ),
                  ...response.data.map((w2r) {
                    return pw.TableRow(
                      children: [
                        _buildPDFCell(w2r.transactionId, fontSize: 8),
                        _buildPDFCell(w2r.originalAccountNo, fontSize: 9),
                        _buildPDFCell(w2r.rightAccountNo, fontSize: 9),
                        _buildPDFCell(w2r.statusDisplay, fontSize: 9),
                        _buildPDFCell(w2r.createdAt, fontSize: 9),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await _saveAndSharePDF(pdf, 'w2r_report');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

  // Helper methods for PDF
  pw.Widget _buildPDFStatBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey400, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPDFCell(
    String text, {
    bool isHeader = false,
    double fontSize = 10,
    pw.TextAlign align = pw.TextAlign.left,
    int maxLines = 1,
  }) {
    // Remove any INR symbols and replace with Rs
    final sanitizedText = text.replaceAll('₹', 'Rs').replaceAll('Rs.', 'Rs.');
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        sanitizedText,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.black,
        ),
        textAlign: align,
        maxLines: maxLines,
      ),
    );
  }

  Future<void> _saveAndSharePDF(pw.Document pdf, String fileName) async {
    try {
      final bytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: widget.reportName);
    } catch (e) {
      showSnack(context, 'Error saving PDF: $e');
    }
  }
}
