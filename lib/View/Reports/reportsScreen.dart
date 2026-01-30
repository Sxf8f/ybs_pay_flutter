import 'package:flutter/material.dart';
import 'package:ybs_pay/View/Reports/widgets/reportsList.dart';
import 'package:ybs_pay/View/widgets/app_bar.dart';

import '../../core/const/color_const.dart';
import '../../main.dart';

class reportsScreen extends StatefulWidget {
  const reportsScreen({super.key});

  @override
  State<reportsScreen> createState() => _reportsScreenState();
}

class _reportsScreenState extends State<reportsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar(),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(scrWidth * 0.04),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: colorConst.primaryColor1.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          Icons.bar_chart,
                          color: colorConst.primaryColor1,
                          size: scrWidth * 0.05,
                        ),
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: scrWidth * 0.04,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reports List
            reportsList(),
          ],
        ),
      ),
    );
  }
}
