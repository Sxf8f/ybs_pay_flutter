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

class UserDaybookScreen extends StatefulWidget {
  const UserDaybookScreen({super.key});

  @override
  State<UserDaybookScreen> createState() => _UserDaybookScreenState();
}

class _UserDaybookScreenState extends State<UserDaybookScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _selectedOperator;

  @override
  void initState() {
    super.initState();
    context.read<DistributorReportBloc>().add(FetchUserDaybookEvent());
  }

  @override
  void dispose() {
    _phoneController.dispose();
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

          // Daybook List
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

                if (state is UserDaybookLoaded) {
                  final daybook = state.daybook;
                  if (daybook.data.isEmpty) {
                    return Center(
                      child: Text(
                        'No daybook entries found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(scrWidth * 0.04),
                    itemCount: daybook.data.length,
                    itemBuilder: (context, index) {
                      final entry = daybook.data[index];
                      return _buildDaybookEntryCard(entry);
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
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: scrWidth * 0.02),
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
              labelText: 'Operator',
              hintText: 'Enter Operator ID or "all"',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _selectedOperator = value.isEmpty ? null : value;
            },
          ),
          SizedBox(height: scrWidth * 0.02),
          ElevatedButton(
            onPressed: () {
              context.read<DistributorReportBloc>().add(
                    FetchUserDaybookEvent(
                      phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
                      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
                      operator: _selectedOperator,
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

  Widget _buildDaybookEntryCard(DaybookEntry entry) {
    final successRate = entry.totalHits > 0
        ? (entry.successHits / entry.totalHits * 100).toStringAsFixed(1)
        : '0.0';

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
                    if (entry.user != null)
                      Text(
                        entry.user!.username,
                        style: TextStyle(
                          fontSize: scrWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: scrWidth * 0.01),
                    if (entry.operator != null)
                      Text(
                        entry.operator!.operatorName,
                        style: TextStyle(
                          fontSize: scrWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                entry.dateTime,
                style: TextStyle(
                  fontSize: scrWidth * 0.032,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          Divider(),
          SizedBox(height: scrWidth * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Hits', entry.totalHits.toString(), Colors.blue),
              _buildStatItem('Success', entry.successHits.toString(), Colors.green),
              _buildStatItem('Failed', entry.failedHits.toString(), Colors.red),
              _buildStatItem('Success Rate', '$successRate%', Colors.purple),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Amount', '₹${entry.totalAmount.toStringAsFixed(2)}', Colors.blue),
              _buildStatItem('Success Amount', '₹${entry.successAmount.toStringAsFixed(2)}', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: scrWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: scrWidth * 0.005),
        Text(
          label,
          style: TextStyle(
            fontSize: scrWidth * 0.028,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

