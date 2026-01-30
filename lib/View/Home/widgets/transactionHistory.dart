import 'package:flutter/material.dart';
import 'package:ybs_pay/View/TransactionHistory/transaction_history.dart';

import '../../../core/const/color_const.dart';
import '../../../main.dart';

class transactionHistory extends StatelessWidget {
  const transactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        top: scrWidth * 0.05,
        bottom: scrWidth * 0.04,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactHistory()),
            );
          },
          borderRadius: BorderRadius.circular(scrWidth * 0.01),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(scrWidth * 0.01),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.25)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scrWidth * 0.04,
                vertical: scrWidth * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(scrWidth * 0.025),
                        decoration: BoxDecoration(
                          color: colorConst.primaryColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(scrWidth * 0.01),
                        ),
                        child: Icon(
                          Icons.history,
                          color: colorConst.primaryColor1,
                          size: scrWidth * 0.04,
                        ),
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Text(
                        "Transaction History",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: scrWidth * 0.033,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    size: scrWidth * 0.03,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
