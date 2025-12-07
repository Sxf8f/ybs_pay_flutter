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
      backgroundColor: Colors.grey.shade200,
      appBar: appBar(),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: reportsList(),
      ),
    );
  }
}
