import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/main.dart';

import '../../../core/const/color_const.dart';
import '../../../core/models/transactionModels/transactionModel.dart';
import '../../../core/repository/disputeW2RRepository/disputeW2RRepo.dart';
import '../../widgets/snackBar.dart';
import '../../TransactionDetails/Transcation.dart';
import '../transaction_history.dart';

class rechargeHistoryListView extends StatefulWidget {
  final String letterpass;
  final List<Transaction> transactions;
  final VoidCallback? onRefresh;
  final Map<int, String>? operatorImageMap; // Map of operator ID -> image path
  const rechargeHistoryListView({
    super.key,
    required this.transactions,
    required this.letterpass,
    this.onRefresh,
    this.operatorImageMap,
  });

  @override
  State<rechargeHistoryListView> createState() =>
      _rechargeHistoryListViewState();
}

class _rechargeHistoryListViewState extends State<rechargeHistoryListView> {
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
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

  Widget _buildStatusBadge(String status, Color color, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
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
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
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

  Future<void> _showDisputeDialog(
    BuildContext context,
    Transaction transaction,
  ) async {
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
                      'Transaction ID: ${transaction.transactionId}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Amount: ₹${transaction.amount}',
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
                              transactionId: transaction.transactionId,
                              remarks: remarksController.text.trim().isEmpty
                                  ? null
                                  : remarksController.text.trim(),
                            );
                            Navigator.of(dialogContext).pop();
                            showSnack(context, response.message);
                            // Refresh the list
                            if (widget.onRefresh != null) {
                              widget.onRefresh!();
                            }
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

  Future<void> _showW2RDialog(
    BuildContext context,
    Transaction transaction,
  ) async {
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
                      'Transaction ID: ${transaction.transactionId}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Current Account: ${transaction.accountNo}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Amount: ₹${transaction.amount}',
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
                              transactionId: transaction.transactionId,
                              rightAccountNo: rightAccountController.text
                                  .trim(),
                              remarks: remarksController.text.trim().isEmpty
                                  ? null
                                  : remarksController.text.trim(),
                            );
                            Navigator.of(dialogContext).pop();
                            showSnack(context, response.message);
                            // Refresh the list
                            if (widget.onRefresh != null) {
                              widget.onRefresh!();
                            }
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

  @override
  Widget build(BuildContext context) {
    Widget _buildTransactionCard(Transaction transaction) {
      // Get operator image from operatorImageMap (from filters.operators)
      final operatorImagePath =
          widget.operatorImageMap?[transaction.operator] ?? '';

      // Debug prints for operator image
      print('🖼️ [TRANSACTION_CARD] Building card for transaction:');
      print('   📝 Transaction ID: ${transaction.transactionId}');
      print('   📝 Operator Name: ${transaction.operatorName}');
      print('   📝 Operator ID: ${transaction.operator}');
      print('   🖼️ Operator Image from map: "$operatorImagePath"');
      print('   🖼️ Operator Image (empty): ${operatorImagePath.isEmpty}');
      print(
        '   🔗 Full Image URL: ${operatorImagePath.isNotEmpty ? (operatorImagePath.startsWith('http') ? operatorImagePath : "${AssetsConst.apiBase}${operatorImagePath.startsWith('/') ? operatorImagePath.substring(1) : operatorImagePath}") : "N/A"}',
      );

      return InkWell(
        onTap: () {
          final operatorImagePath =
              widget.operatorImageMap?[transaction.operator] ?? '';
          print('🔘 [TRANSACTION_CARD] Tapped transaction:');
          print('   🖼️ Operator Image: "$operatorImagePath"');
          print(
            '   🔗 Full URL: ${operatorImagePath.isNotEmpty ? (operatorImagePath.startsWith('http') ? operatorImagePath : "${AssetsConst.apiBase}${operatorImagePath.startsWith('/') ? operatorImagePath.substring(1) : operatorImagePath}") : "N/A"}',
          );
          Navigator.push(
            context,
            PageTransition(
              alignment: Alignment.bottomCenter,
              curve: Curves.easeInOut,
              duration: const Duration(seconds: 1),
              reverseDuration: const Duration(seconds: 1),
              type: PageTransitionType.theme,
              child: Transaction_page(
                providerImage: operatorImagePath,
                providerText: transaction.operatorName,
                providernumber: transaction.phoneNumber,
                providerrate: "₹${transaction.amount}",
                providerstatus: transaction.statusName,
                providermobilenum: transaction.phoneNumber,
                provideroperator: transaction.operatorName,
                provideramount: "₹${transaction.amount}",
                providertransid: transaction.transactionId,
                providerliveid: transaction.liveid,
                providerdate: transaction.datetime,
                providertime: transaction.statusName,
              ),
              childCurrent: TransactHistory(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                operatorImagePath.isNotEmpty &&
                                    operatorImagePath != '/' &&
                                    operatorImagePath != 'null'
                                ? CachedNetworkImage(
                                    imageUrl:
                                        operatorImagePath.startsWith('http')
                                        ? operatorImagePath
                                        : "${AssetsConst.apiBase}${operatorImagePath.startsWith('/') ? operatorImagePath.substring(1) : operatorImagePath}",
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                colorConst.primaryColor1,
                                              ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      print(
                                        '❌ [TRANSACTION_HISTORY] Image load error:',
                                      );
                                      print('   🔗 URL: $url');
                                      print('   📝 Error: $error');
                                      print(
                                        '   📝 Transaction ID: ${transaction.transactionId}',
                                      );
                                      print(
                                        '   📝 Operator: ${transaction.operatorName}',
                                      );
                                      print(
                                        '   📝 Operator ID: ${transaction.operator}',
                                      );
                                      return Icon(
                                        Icons.phone_android,
                                        color: colorConst.primaryColor1,
                                        size: 20,
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.phone_android,
                                    color: colorConst.primaryColor1,
                                    size: 20,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.operatorName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: scrWidth * 0.035,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              transaction.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: scrWidth * 0.025,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${transaction.amount}",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: scrWidth * 0.038,
                            color: colorConst.primaryColor1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              transaction.statusName,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            transaction.statusName.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(transaction.statusName),
                              fontSize: scrWidth * 0.025,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trans ID: ${transaction.transactionId}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (transaction.liveid.isNotEmpty &&
                        transaction.liveid != 'null')
                      Text(
                        "Live ID: ${transaction.liveid}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      transaction.datetime,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Dispute and W2R status/buttons
                // Show for SUCCESS transactions, or for FAILED transactions with dispute/W2R status
                if (transaction.statusName.toUpperCase() == 'SUCCESS' ||
                    (transaction.statusName.toUpperCase() == 'FAILED' &&
                        (transaction.disputeRequested == true ||
                            (transaction.refundStatus.isNotEmpty &&
                                transaction.refundStatus != 'DISPUTE') ||
                            (transaction.w2rStatus != null &&
                                transaction.w2rStatus!.isNotEmpty)))) ...[
                  SizedBox(height: 12),
                  Divider(height: 1, color: Colors.grey[200]),
                  SizedBox(height: 12),
                  // Dispute Status/Button
                  if (transaction.disputeRequested == true ||
                      (transaction.refundStatus.isNotEmpty &&
                          transaction.refundStatus != 'DISPUTE')) ...[
                    // Show dispute status badge
                    Row(
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            size: 14, color: Colors.orange),
                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dispute Status',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              _buildStatusBadge(
                                transaction.refundStatusDisplay ??
                                    _getRefundStatusDisplay(
                                        transaction.refundStatus.isEmpty
                                            ? null
                                            : transaction.refundStatus),
                                _getRefundStatusColor(
                                    transaction.refundStatus.isEmpty
                                        ? null
                                        : transaction.refundStatus),
                                _getRefundStatusColor(
                                        transaction.refundStatus.isEmpty
                                            ? null
                                            : transaction.refundStatus)
                                    .withOpacity(0.1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (transaction.statusName.toUpperCase() == 'SUCCESS') ...[
                    // Show dispute button only for SUCCESS transactions
                    _buildActionButton(
                      icon: Icons.warning_amber_outlined,
                      label: 'Raise Dispute',
                      color: Colors.orange,
                      onTap: () => _showDisputeDialog(context, transaction),
                    ),
                  ],
                  // W2R Status/Button
                  if (transaction.w2rAllowed == true) ...[
                    if (transaction.w2rStatus != null &&
                        transaction.w2rStatus!.isNotEmpty) ...[
                      // Show W2R status badge
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.swap_horiz,
                              size: 14, color: Colors.blue),
                          SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wrong to Right Status',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                _buildStatusBadge(
                                  _getW2RStatusDisplay(transaction.w2rStatus),
                                  _getW2RStatusColor(transaction.w2rStatus),
                                  _getW2RStatusColor(transaction.w2rStatus)
                                      .withOpacity(0.1),
                                ),
                                // Show account numbers if W2R is accepted
                                if (transaction.w2rStatus?.toUpperCase() ==
                                        'ACCEPTED' &&
                                    transaction.w2rRightAccountNo != null &&
                                    transaction.w2rRightAccountNo!.isNotEmpty) ...[
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.arrow_downward,
                                          size: 12, color: Colors.red),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Wrong: ${transaction.accountNo}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.arrow_upward,
                                          size: 12, color: Colors.green),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Right: ${transaction.w2rRightAccountNo}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (transaction.statusName.toUpperCase() == 'SUCCESS') ...[
                      // Show W2R button only for SUCCESS transactions
                      SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.swap_horiz,
                        label: 'Wrong to Right',
                        color: Colors.blue,
                        onTap: () => _showW2RDialog(context, transaction),
                      ),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
        },
        child: widget.transactions.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Image.asset(
                      'assets/images/no-result-data-1.jpg',
                      height: 130,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('No Data Available with ${widget.letterpass}'),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.transactions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = widget.transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
      ),
    );
  }
}
