import 'package:flutter/material.dart';

import '../../../main.dart';

/// A address container with address icon and address

class addressBox extends StatelessWidget {
  final String address;

  const addressBox({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(scrWidth * 0.01),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(scrWidth * 0.025),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(scrWidth * 0.01),
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: scrWidth * 0.04,
              ),
            ),
            SizedBox(width: scrWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth * 0.033,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.02),
                  Text(
                    address,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: scrWidth * 0.029,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
