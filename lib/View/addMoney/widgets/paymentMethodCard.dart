import 'package:flutter/material.dart';
import '../../../core/models/walletModels/walletModel.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chargeInfo = paymentMethod.chargeInfo;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scrWidth * 0.02),
        child: Container(
          padding: EdgeInsets.all(scrWidth * 0.035),
          decoration: BoxDecoration(
            color: isSelected
                ? colorConst.primaryColor1.withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? colorConst.primaryColor1
                  : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with payment method name and selection indicator
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getPaymentMethodIcon(paymentMethod.operator),
                          color: isSelected
                              ? colorConst.primaryColor1
                              : Colors.grey[700],
                          size: scrWidth * 0.05,
                        ),
                        SizedBox(width: scrWidth * 0.02),
                        Expanded(
                          child: Text(
                            paymentMethod.operatorDisplay,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: scrWidth * 0.04,
                              color: isSelected
                                  ? colorConst.primaryColor1
                                  : Colors.grey[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(scrWidth * 0.01),
                      decoration: BoxDecoration(
                        color: colorConst.primaryColor1,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: scrWidth * 0.03,
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: scrWidth * 0.03),
              
              // Gateway name
              Text(
                'Via ${paymentMethod.gatewayName}',
                style: TextStyle(
                  fontSize: scrWidth * 0.028,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              SizedBox(height: scrWidth * 0.03),
              
              // Charge info
              if (chargeInfo != null) ...[
                Container(
                  padding: EdgeInsets.all(scrWidth * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Charge display
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: scrWidth * 0.03,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: scrWidth * 0.015),
                          Text(
                            'Charge: ',
                            style: TextStyle(
                              fontSize: scrWidth * 0.028,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            chargeInfo.chargeDisplay,
                            style: TextStyle(
                              fontSize: scrWidth * 0.028,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: scrWidth * 0.02),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: scrWidth * 0.02,
                              vertical: scrWidth * 0.008,
                            ),
                            decoration: BoxDecoration(
                              color: colorConst.primaryColor1.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(scrWidth * 0.01),
                            ),
                            child: Text(
                              chargeInfo.chargeType,
                              style: TextStyle(
                                fontSize: scrWidth * 0.025,
                                color: colorConst.primaryColor1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: scrWidth * 0.02),
                      
                      // Min/Max amounts
                      Row(
                        children: [
                          Expanded(
                            child: _buildAmountRange(
                              'Min',
                              chargeInfo.minAmountDisplay,
                              Icons.arrow_downward,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: scrWidth * 0.04,
                            color: Colors.grey[300],
                          ),
                          SizedBox(width: scrWidth * 0.02),
                          Expanded(
                            child: _buildAmountRange(
                              'Max',
                              chargeInfo.maxAmountDisplay,
                              Icons.arrow_upward,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // No charge info available
                Container(
                  padding: EdgeInsets.all(scrWidth * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: scrWidth * 0.03,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: scrWidth * 0.015),
                      Text(
                        'Charge information not available',
                        style: TextStyle(
                          fontSize: scrWidth * 0.028,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRange(String label, String amount, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: scrWidth * 0.025,
          color: Colors.grey[600],
        ),
        SizedBox(width: scrWidth * 0.01),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: scrWidth * 0.025,
                color: Colors.grey[600],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: scrWidth * 0.028,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(String operator) {
    switch (operator.toLowerCase()) {
      case 'upi_collect':
        return Icons.account_balance_wallet;
      case 'credit_card':
        return Icons.credit_card;
      case 'debit_card':
        return Icons.credit_card_outlined;
      case 'net_banking':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}

