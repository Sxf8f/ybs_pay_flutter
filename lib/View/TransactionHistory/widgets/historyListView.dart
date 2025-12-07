import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/main.dart';

import '../../../core/const/color_const.dart';
import '../../../core/models/transactionModels/transactionModel.dart';
import '../../TransactionDetails/Transcation.dart';
import '../transaction_history.dart';

class rechargeHistoryListView extends StatelessWidget {
  final String letterpass;
  final List<Transaction> transactions;
  final VoidCallback? onRefresh;
  rechargeHistoryListView({
    super.key,
    required this.transactions,
    required this.letterpass,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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

    Widget _buildTransactionCard(Transaction transaction) {
      return InkWell(
        onTap: () {
          print(transaction.operatorImage);
          print("${AssetsConst.apiBase}${transaction.operatorImage}");
          Navigator.push(
            context,
            PageTransition(
              alignment: Alignment.bottomCenter,
              curve: Curves.easeInOut,
              duration: const Duration(seconds: 1),
              reverseDuration: const Duration(seconds: 1),
              type: PageTransitionType.theme,
              child: Transaction_page(
                providerImage: transaction.operatorImage,
                providerText: transaction.operatorName,
                providernumber: transaction.phoneNumber,
                providerrate: "₹${transaction.amount}",
                providerstatus: transaction.statusName,
                providermobilenum: transaction.phoneNumber,
                provideroperator: transaction.operatorName,
                provideramount: "₹${transaction.amount}",
                providertransid: transaction.transactionId,
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
                            image: DecorationImage(
                              image: NetworkImage(
                                "${AssetsConst.apiBase}${transaction.operatorImage}",
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: transaction.operatorImage.isNotEmpty
                              ? SizedBox.shrink()
                              : Icon(
                                  Icons.phone_android,
                                  color: colorConst.primaryColor1,
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
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          if (onRefresh != null) {
            onRefresh!();
          }
        },
        child: transactions.isEmpty
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
                  Text('No Data Available with $letterpass'),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: transactions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
      ),
    );
  }
}
