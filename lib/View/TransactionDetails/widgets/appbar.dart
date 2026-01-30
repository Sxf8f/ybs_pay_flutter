import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../main.dart';

class appBarForTransactionPage extends StatelessWidget
    implements PreferredSizeWidget {
  final providersatus;
  final providertransid;
  const appBarForTransactionPage({
    super.key,
    required this.providersatus,
    required this.providertransid,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    if (providersatus == 'FAILED') {
      statusColor = Colors.red;
      statusIcon = Icons.dangerous;
    } else if (providersatus == 'SUCCESS') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    }

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trans ID: $providertransid",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              providersatus.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: scrWidth * 0.025,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
        ),
      ],
    );
  }
}
