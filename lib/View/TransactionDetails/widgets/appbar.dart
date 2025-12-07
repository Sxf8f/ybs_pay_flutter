import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.close),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trans ID : $providertransid",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            providersatus,
            style: TextStyle(
              color: providersatus == 'FAILED'
                  ? Colors.red
                  : providersatus == 'SUCCESS'
                  ? Colors.green
                  : Colors.orange,
              fontSize: 10,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(
            providersatus == 'FAILED'
                ? Icons.dangerous
                : providersatus == 'PENDING'
                ? Icons.pending
                : Icons.check_circle,
            color: Colors.green,
            size: 30,
          ),
        ),
      ],
    );
  }
}
