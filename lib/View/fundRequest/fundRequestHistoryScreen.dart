import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/core/repository/fundRequestRepository/fundRequestRepo.dart';
import 'package:ybs_pay/core/models/fundRequestModels/fundRequestModel.dart';
import 'package:ybs_pay/core/const/color_const.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/core/bloc/appBloc/appBloc.dart';
import 'package:ybs_pay/core/bloc/appBloc/appState.dart';
import 'package:ybs_pay/main.dart';
import 'package:ybs_pay/View/widgets/snackBar.dart';
import 'fundRequestDetailsScreen.dart';
import 'fundRequestFormScreen.dart';

class FundRequestHistoryScreen extends StatefulWidget {
  const FundRequestHistoryScreen({super.key});

  @override
  State<FundRequestHistoryScreen> createState() =>
      _FundRequestHistoryScreenState();
}

class _FundRequestHistoryScreenState extends State<FundRequestHistoryScreen> {
  final FundRequestRepository _repository = FundRequestRepository();

  List<FundRequest> fundRequests = [];
  bool isLoading = false;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({String? status}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _repository.getFundRequestHistory(
        status: status,
        limit: 50,
      );
      setState(() {
        fundRequests = response.fundRequests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSnack(context, 'Failed to load history: $e');
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Right: Empty space
                  SizedBox(width: scrWidth * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FundRequestFormScreen(),
            ),
          ).then((_) {
            // Refresh history when returning from form
            _loadHistory(status: selectedStatus);
          });
        },
        backgroundColor: colorConst.primaryColor3,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Request',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: scrWidth * 0.035,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter buttons
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildFilterButton('All', null)),
                SizedBox(width: 8),
                Expanded(child: _buildFilterButton('Pending', 'PENDING')),
                SizedBox(width: 8),
                Expanded(child: _buildFilterButton('Approved', 'APPROVED')),
                SizedBox(width: 8),
                Expanded(child: _buildFilterButton('Rejected', 'REJECTED')),
              ],
            ),
          ),

          // List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : fundRequests.isEmpty
                ? Center(
                    child: Text(
                      'No fund requests found',
                      style: TextStyle(
                        fontSize: scrWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: fundRequests.length,
                    itemBuilder: (context, index) {
                      final request = fundRequests[index];
                      return _buildRequestCard(request);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String? status) {
    final isSelected = selectedStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
        _loadHistory(status: status);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorConst.primaryColor3 : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: scrWidth * 0.03,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(FundRequest request) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FundRequestDetailsScreen(fundRequestId: request.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${request.amount}',
                    style: TextStyle(
                      fontSize: scrWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: colorConst.primaryColor3,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status,
                      style: TextStyle(
                        fontSize: scrWidth * 0.028,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(request.status),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Transaction ID: ${request.transactionId}',
                style: TextStyle(
                  fontSize: scrWidth * 0.03,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Bank: ${request.bankName}',
                style: TextStyle(
                  fontSize: scrWidth * 0.03,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mode: ${request.transferMode}',
                style: TextStyle(
                  fontSize: scrWidth * 0.03,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(request.entryDate),
                    style: TextStyle(
                      fontSize: scrWidth * 0.028,
                      color: Colors.grey[500],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
