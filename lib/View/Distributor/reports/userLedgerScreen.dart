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

class UserLedgerScreen extends StatefulWidget {
  const UserLedgerScreen({super.key});

  @override
  State<UserLedgerScreen> createState() => _UserLedgerScreenState();
}

class _UserLedgerScreenState extends State<UserLedgerScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();

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
          ElevatedButton(
            onPressed: () {
              context.read<DistributorReportBloc>().add(
                    FetchUserLedgerEvent(
                      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
                      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
                      transactionId: _transactionIdController.text.isNotEmpty ? _transactionIdController.text : null,
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
                    if (entry.description != null && entry.description!.isNotEmpty) ...[
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
                    '+₹${entry.credit.toStringAsFixed(2)}',
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
                    '-₹${entry.debited.toStringAsFixed(2)}',
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
}

