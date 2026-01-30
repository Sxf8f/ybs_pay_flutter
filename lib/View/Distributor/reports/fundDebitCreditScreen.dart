import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/distributorBloc/distributorReportBloc.dart';
import '../../../core/bloc/distributorBloc/distributorReportEvent.dart';
import '../../../core/bloc/distributorBloc/distributorReportState.dart';
import '../../../core/models/distributorModels/distributorReportModel.dart';
import '../../../core/repository/distributorRepository/distributorRepo.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../widgets/app_bar.dart';

class FundDebitCreditScreen extends StatefulWidget {
  const FundDebitCreditScreen({super.key});

  @override
  State<FundDebitCreditScreen> createState() => _FundDebitCreditScreenState();
}

class _FundDebitCreditScreenState extends State<FundDebitCreditScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  int? _selectedWalletType;
  String? _selectedType; // "credit" or "debit"

  @override
  void initState() {
    super.initState();
    context.read<DistributorReportBloc>().add(FetchFundDebitCreditEvent());
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _mobileController.dispose();
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

          // Report List
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

                if (state is FundDebitCreditLoaded) {
                  final report = state.report;
                  if (report.data.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(scrWidth * 0.04),
                    itemCount: report.data.length,
                    itemBuilder: (context, index) {
                      final entry = report.data[index];
                      return _buildTransactionCard(entry);
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: scrWidth * 0.02),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'credit', child: Text('Credit')),
                    DropdownMenuItem(value: 'debit', child: Text('Debit')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          ElevatedButton(
            onPressed: () {
              context.read<DistributorReportBloc>().add(
                    FetchFundDebitCreditEvent(
                      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
                      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
                      mobile: _mobileController.text.isNotEmpty ? _mobileController.text : null,
                      type: _selectedType,
                      walletType: _selectedWalletType,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorConst.primaryColor1,
              minimumSize: Size(double.infinity, scrWidth * 0.12),
            ),
            child: Text('Apply Filters', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(FundDebitCreditEntry entry) {
    final isCredit = entry.debitCreditType.toLowerCase() == 'credit';
    return Container(
      margin: EdgeInsets.only(bottom: scrWidth * 0.03),
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCredit ? Colors.green.shade300 : Colors.red.shade300,
        ),
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
                      'Transaction #${entry.id}',
                      style: TextStyle(
                        fontSize: scrWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.service != null) ...[
                      SizedBox(height: scrWidth * 0.01),
                      Text(
                        entry.service!,
                        style: TextStyle(
                          fontSize: scrWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scrWidth * 0.03,
                  vertical: scrWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isCredit ? '+' : '-'}₹${entry.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          Divider(),
          SizedBox(height: scrWidth * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (entry.walletType != null)
                Text(
                  entry.walletType!.name,
                  style: TextStyle(
                    fontSize: scrWidth * 0.032,
                    color: Colors.grey[600],
                  ),
                )
              else if (entry.service != null)
                Text(
                  entry.service!,
                  style: TextStyle(
                    fontSize: scrWidth * 0.032,
                    color: Colors.grey[600],
                  ),
                ),
              Text(
                entry.entryDate,
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
}

