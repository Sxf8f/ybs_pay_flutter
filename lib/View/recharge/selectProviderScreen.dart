import 'package:flutter/material.dart';
import 'package:ybs_pay/View/recharge/rechargeScreen.dart';
import 'package:ybs_pay/View/recharge/widgets/appBarInSelectProviderScreen.dart';
import 'package:ybs_pay/View/recharge/widgets/rechargeProviderGrid.dart';

import '../../main.dart';

class selectProvider extends StatefulWidget {
  const selectProvider({super.key});

  @override
  State<selectProvider> createState() => _selectProviderState();
}

class _selectProviderState extends State<selectProvider> {
/// list for the recharge provider list with data like image and name
  List providersList=[
    {'name':'Airtel','image':'assets/images/providers/airtel.png'},
    {'name':'BSNL','image':'assets/images/providers/bsnl.png'},
    {'name':'vi','image':'assets/images/providers/vi.png'},
    {'name':'Jio','image':'assets/images/providers/jio.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// appbar of the select provider screen
      appBar: appBarInSelectProviderScreen(),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20,),

            /// recharge provider names with logos
            rechargeProviderGrid(providersList: providersList,),

            SizedBox(height: 30,),

          ],
        ),
      ),
    );

  }
}
