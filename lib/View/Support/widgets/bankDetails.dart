import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';
import '../../../core/models/supportModels/supportModel.dart';
import '../../../main.dart';

/// A container button for bank details

class bankDetailsBox extends StatelessWidget {
  final BankDetails data;

  const bankDetailsBox({super.key, required this.data});

  void _showBankDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: Text(
            'Bank Details',
            style: TextStyle(
              fontSize: scrWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: colorConst.primaryColor1,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.bankName.isNotEmpty) ...[
                  _buildDetailRow(context, 'Bank Name', data.bankName),
                  SizedBox(height: 12),
                ],
                if (data.accountHolderName.isNotEmpty) ...[
                  _buildDetailRow(
                    context,
                    'Account Holder',
                    data.accountHolderName,
                  ),
                  SizedBox(height: 12),
                ],
                if (data.accountNumber.isNotEmpty) ...[
                  _buildDetailRow(context, 'Account Number', data.accountNumber),
                  SizedBox(height: 12),
                ],
                if (data.ifscCode.isNotEmpty) ...[
                  _buildDetailRow(context, 'IFSC Code', data.ifscCode),
                  SizedBox(height: 12),
                ],
                if (data.branch.isNotEmpty) ...[
                  _buildDetailRow(context, 'Branch', data.branch),
                  SizedBox(height: 12),
                ],
                if (data.branchAddress.isNotEmpty) ...[
                  _buildDetailRow(context, 'Branch Address', data.branchAddress),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: colorConst.primaryColor1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: scrWidth * 0.03,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: scrWidth * 0.03,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBankDetailsDialog(context),
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(scrWidth * 0.01),
            border: Border.all(
              color: Colors.green.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(scrWidth * 0.04),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(scrWidth * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(scrWidth * 0.01),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.green,
                    size: scrWidth * 0.04,
                  ),
                ),
                SizedBox(width: scrWidth * 0.03),
                Expanded(
                  child: Text(
                    'Bank Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth * 0.033,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                  size: scrWidth * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
