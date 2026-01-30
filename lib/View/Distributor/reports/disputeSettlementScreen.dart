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

class DisputeSettlementScreen extends StatefulWidget {
  const DisputeSettlementScreen({super.key});

  @override
  State<DisputeSettlementScreen> createState() => _DisputeSettlementScreenState();
}

class _DisputeSettlementScreenState extends State<DisputeSettlementScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<DistributorReportBloc>().add(FetchDisputeSettlementEvent());
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
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

          // Dispute List
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

                if (state is DisputeSettlementLoaded) {
                  final dispute = state.dispute;
                  if (dispute.data.isEmpty) {
                    return Center(
                      child: Text(
                        'No dispute records found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(scrWidth * 0.04),
                    itemCount: dispute.data.length,
                    itemBuilder: (context, index) {
                      final entry = dispute.data[index];
                      return _buildDisputeCard(entry);
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
            decoration: InputDecoration(
              labelText: 'Refund Status',
              hintText: 'e.g., under-review, approved, rejected',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _selectedStatus = value.isEmpty ? null : value;
            },
          ),
          SizedBox(height: scrWidth * 0.02),
          ElevatedButton(
            onPressed: () {
              context.read<DistributorReportBloc>().add(
                    FetchDisputeSettlementEvent(
                      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
                      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
                      status: _selectedStatus,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorConst.primaryColor1,
              minimumSize: Size(double.infinity, scrWidth * 0.12),
            ),
            child: Text('Apply Filters', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeCard(DisputeSettlementEntry entry) {
    Color statusColor;
    switch (entry.refundStatus.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'under-review':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

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
                    SizedBox(height: scrWidth * 0.01),
                    Text(
                      '₹${entry.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: scrWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: colorConst.primaryColor1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scrWidth * 0.03,
                  vertical: scrWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  entry.refundStatus,
                  style: TextStyle(
                    fontSize: scrWidth * 0.028,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (entry.operator != null) ...[
            SizedBox(height: scrWidth * 0.01),
            Text(
              'Operator: ${entry.operator!.operatorName}',
              style: TextStyle(
                fontSize: scrWidth * 0.03,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (entry.reason != null && entry.reason!.isNotEmpty) ...[
            SizedBox(height: scrWidth * 0.02),
            Divider(),
            SizedBox(height: scrWidth * 0.02),
            Text(
              'Reason: ${entry.reason}',
              style: TextStyle(
                fontSize: scrWidth * 0.032,
                color: Colors.grey[700],
              ),
            ),
          ],
          SizedBox(height: scrWidth * 0.02),
          Text(
            entry.requestDate,
            style: TextStyle(
              fontSize: scrWidth * 0.028,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

