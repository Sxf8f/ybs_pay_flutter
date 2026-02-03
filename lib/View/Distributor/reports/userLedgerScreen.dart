import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../core/bloc/distributorBloc/distributorReportBloc.dart';
import '../../../core/bloc/distributorBloc/distributorReportEvent.dart';
import '../../../core/bloc/distributorBloc/distributorReportState.dart';
import '../../../core/models/distributorModels/distributorReportModel.dart';
import '../../../core/const/color_const.dart';
import '../../../core/const/assets_const.dart';
import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appState.dart';
import '../../../main.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/snackBar.dart';

class UserLedgerScreen extends StatefulWidget {
  const UserLedgerScreen({super.key});

  @override
  State<UserLedgerScreen> createState() => _UserLedgerScreenState();
}

class _UserLedgerScreenState extends State<UserLedgerScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DistributorReportBloc>().add(FetchUserLedgerEvent());
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Ledger List
          Expanded(
            child: BlocBuilder<DistributorReportBloc, DistributorReportState>(
              builder: (context, state) {
                if (state is DistributorReportLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is DistributorReportError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                      ],
                    ),
                  );
                }

                if (state is UserLedgerLoaded) {
                  final ledger = state.ledger;
                  if (ledger.data.isEmpty) {
                    return Center(
                      child: Text(
                        'No ledger entries found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(scrWidth * 0.04),
                    itemCount: ledger.data.length,
                    itemBuilder: (context, index) {
                      final entry = ledger.data[index];
                      return _buildLedgerEntryCard(entry);
                    },
                  );
                }

                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: scrWidth * 0.02),
              Expanded(
                child: TextField(
                  controller: _endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          TextField(
            controller: _transactionIdController,
            decoration: InputDecoration(
              labelText: 'Transaction ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: scrWidth * 0.02),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<DistributorReportBloc>().add(
                      FetchUserLedgerEvent(
                        startDate: _startDateController.text.isNotEmpty
                            ? _startDateController.text
                            : null,
                        endDate: _endDateController.text.isNotEmpty
                            ? _endDateController.text
                            : null,
                        transactionId: _transactionIdController.text.isNotEmpty
                            ? _transactionIdController.text
                            : null,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorConst.primaryColor1,
                    minimumSize: Size(double.infinity, scrWidth * 0.12),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: scrWidth * 0.02),
              BlocBuilder<DistributorReportBloc, DistributorReportState>(
                builder: (context, state) {
                  if (state is UserLedgerLoaded &&
                      state.ledger.data.isNotEmpty) {
                    return IconButton(
                      icon: Icon(
                        Icons.picture_as_pdf,
                        color: colorConst.primaryColor1,
                        size: 28,
                      ),
                      onPressed: () => _generateUserLedgerPDF(state.ledger),
                      tooltip: 'Download PDF',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.all(12),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerEntryCard(LedgerEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: scrWidth * 0.03),
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
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
                      entry.transactionId,
                      style: TextStyle(
                        fontSize: scrWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.description != null &&
                        entry.description!.isNotEmpty) ...[
                      SizedBox(height: scrWidth * 0.01),
                      Text(
                        entry.description!,
                        style: TextStyle(
                          fontSize: scrWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.credit > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scrWidth * 0.03,
                    vertical: scrWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${entry.credit.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (entry.debited > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scrWidth * 0.03,
                    vertical: scrWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${entry.debited.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (entry.user != null) ...[
            SizedBox(height: scrWidth * 0.01),
            Text(
              'User: ${entry.user!.username}${entry.user!.phoneNumber != null ? ' (${entry.user!.phoneNumber})' : ''}',
              style: TextStyle(
                fontSize: scrWidth * 0.03,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: scrWidth * 0.02),
          Divider(),
          SizedBox(height: scrWidth * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (entry.dateTimeFormatted != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.dateTimeFormatted!.date,
                      style: TextStyle(
                        fontSize: scrWidth * 0.032,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      entry.dateTimeFormatted!.time,
                      style: TextStyle(
                        fontSize: scrWidth * 0.028,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              else
                Text(
                  entry.dateTime,
                  style: TextStyle(
                    fontSize: scrWidth * 0.028,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateUserLedgerPDF(UserLedgerResponse ledger) async {
    try {
      // Load logo
      pw.ImageProvider? logoImage;
      try {
        final appState = context.read<AppBloc>().state;
        String? logoUrl;
        if (appState is AppLoaded && appState.settings?.logo != null) {
          logoUrl =
              "${AssetsConst.apiBase}media/${appState.settings!.logo!.image}";
        }

        if (logoUrl != null && logoUrl.startsWith('http')) {
          final logoResponse = await http.get(Uri.parse(logoUrl));
          if (logoResponse.statusCode == 200) {
            final logoBytes = logoResponse.bodyBytes;
            logoImage = pw.MemoryImage(logoBytes);
          }
        }
      } catch (e) {
        print('Error loading logo: $e');
      }

      final pdf = pw.Document();

      // Calculate closing balance
      double closingBalance = 0.0;
      if (ledger.data.isNotEmpty) {
        for (var entry in ledger.data) {
          closingBalance += entry.credit - entry.debited;
        }
      }

      // Get filter info
      String filterInfo = 'No filters applied';
      List<String> filters = [];
      if (_startDateController.text.isNotEmpty) {
        filters.add('Start Date: ${_startDateController.text}');
      }
      if (_endDateController.text.isNotEmpty) {
        filters.add('End Date: ${_endDateController.text}');
      }
      if (_transactionIdController.text.isNotEmpty) {
        filters.add('Transaction ID: ${_transactionIdController.text}');
      }
      if (filters.isNotEmpty) {
        filterInfo = filters.join(' | ');
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Logo Header (Centered)
              if (logoImage != null)
                pw.Center(
                  child: pw.Image(
                    logoImage,
                    height: 40,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              if (logoImage != null) pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  'User Ledger Statement',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  filterInfo,
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
                  _buildPDFStatBox(
                    'Closing Balance',
                    'Rs.${closingBalance.toStringAsFixed(2)}',
                  ),
                  _buildPDFStatBox(
                    'Total Transactions',
                    ledger.returnedCount.toString(),
                  ),
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
                      _buildPDFCell('Description', isHeader: true),
                      _buildPDFCell(
                        'Credit',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                      _buildPDFCell(
                        'Debit',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                      _buildPDFCell('User', isHeader: true),
                    ],
                  ),
                  ...ledger.data.map((entry) {
                    final displayDate = entry.dateTimeFormatted != null
                        ? '${entry.dateTimeFormatted!.date} ${entry.dateTimeFormatted!.time}'
                        : entry.dateTime;

                    return pw.TableRow(
                      children: [
                        _buildPDFCell(displayDate, fontSize: 9),
                        _buildPDFCell(
                          entry.transactionId.length > 15
                              ? '${entry.transactionId.substring(0, 15)}...'
                              : entry.transactionId,
                          fontSize: 8,
                        ),
                        _buildPDFCell(
                          entry.description ?? '',
                          fontSize: 9,
                          maxLines: 2,
                        ),
                        _buildPDFCell(
                          entry.credit > 0
                              ? 'Rs.${entry.credit.toStringAsFixed(2)}'
                              : '-',
                          fontSize: 9,
                          align: pw.TextAlign.right,
                        ),
                        _buildPDFCell(
                          entry.debited > 0
                              ? 'Rs.${entry.debited.toStringAsFixed(2)}'
                              : '-',
                          fontSize: 9,
                          align: pw.TextAlign.right,
                        ),
                        _buildPDFCell(
                          entry.user != null
                              ? '${entry.user!.username}${entry.user!.phoneNumber != null ? ' (${entry.user!.phoneNumber})' : ''}'
                              : '-',
                          fontSize: 8,
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

      // Save and share PDF
      final bytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/user_ledger_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'User Ledger Statement');
    } catch (e) {
      showSnack(context, 'Error generating PDF: $e');
    }
  }

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
}
