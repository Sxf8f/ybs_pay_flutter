import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ybs_pay/core/repository/fundRequestRepository/fundRequestRepo.dart';
import 'package:ybs_pay/core/models/fundRequestModels/fundRequestModel.dart';
import 'package:ybs_pay/core/const/color_const.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/main.dart';
import 'package:ybs_pay/View/widgets/snackBar.dart';

class FundRequestDetailsScreen extends StatefulWidget {
  final int fundRequestId;

  const FundRequestDetailsScreen({
    super.key,
    required this.fundRequestId,
  });

  @override
  State<FundRequestDetailsScreen> createState() => _FundRequestDetailsScreenState();
}

class _FundRequestDetailsScreenState extends State<FundRequestDetailsScreen> {
  final FundRequestRepository _repository = FundRequestRepository();
  
  FundRequest? fundRequest;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _repository.getFundRequestDetails(widget.fundRequestId);
      setState(() {
        fundRequest = response.fundRequest;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSnack(context, 'Failed to load details: $e');
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Fund Request Details',
          style: TextStyle(
            fontSize: scrWidth * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : fundRequest == null
              ? Center(
                  child: Text(
                    'Fund request not found',
                    style: TextStyle(
                      fontSize: scrWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _getStatusColor(fundRequest!.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(fundRequest!.status),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: scrWidth * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              fundRequest!.status,
                              style: TextStyle(
                                fontSize: scrWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(fundRequest!.status),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '₹${fundRequest!.amount}',
                              style: TextStyle(
                                fontSize: scrWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: colorConst.primaryColor3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Transaction Details
                      _buildDetailRow('Transaction ID', fundRequest!.transactionId),
                      _buildDetailRow('Date', _formatDate(fundRequest!.entryDate)),
                      _buildDetailRow('Bank', fundRequest!.bankName),
                      _buildDetailRow('Account Holder', fundRequest!.accountHolder),
                      _buildDetailRow('Account Number', fundRequest!.accountNumber),
                      _buildDetailRow('IFSC Code', fundRequest!.ifscCode),
                      _buildDetailRow('Branch', fundRequest!.branch),
                      _buildDetailRow('Transfer Mode', fundRequest!.transferMode),
                      _buildDetailRow('Wallet Type', fundRequest!.walletType),
                      if (fundRequest!.mobileNo != null)
                        _buildDetailRow('Mobile Number', fundRequest!.mobileNo!),
                      if (fundRequest!.remark != null && fundRequest!.remark!.isNotEmpty)
                        _buildDetailRow('Remark', fundRequest!.remark!),
                      
                      // Receipt
                      if (fundRequest!.receiptUrl != null) ...[
                        SizedBox(height: 16),
                        Text(
                          'Receipt',
                          style: TextStyle(
                            fontSize: scrWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: scrWidth * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: '${AssetsConst.apiBase}${fundRequest!.receiptUrl!.startsWith('/') ? fundRequest!.receiptUrl!.substring(1) : fundRequest!.receiptUrl}',
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(Icons.error, size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: scrWidth * 0.032,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: scrWidth * 0.032,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

