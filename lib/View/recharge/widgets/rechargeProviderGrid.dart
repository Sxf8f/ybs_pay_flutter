import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../rechargeScreen.dart';


class rechargeProviderGrid extends StatelessWidget {
  final List providersList;
  const rechargeProviderGrid({super.key, required this.providersList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0,left: 8),
      child: GridView.builder(
          itemCount: providersList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 15
          ),
          itemBuilder: (context, index) {
            final provider= providersList[index];
            return Padding(
              padding: const EdgeInsets.only(right: 10,left: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => rechargeScreen(rechargeProviderName: provider['name']),));
                },
                child: Container(
                  // color: Colors.grey.shade300,
                  // height: MediaQuery.of(context).size.width*0.14,
                  width: MediaQuery.of(context).size.width*0.4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(scrWidth*0.05),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 2,
                            // blurStyle: BlurStyle.outer,
                            offset: Offset(4, 4),
                            spreadRadius: 1
                        )
                      ]
                  ),
                  child: Padding(
                    padding: const  EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 25,
                      bottom: 18,
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(image: AssetImage(provider['image']),fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(scrWidth*0.03),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 2,
                                    // blurStyle: BlurStyle.outer,
                                    offset: Offset(2, 2),
                                    spreadRadius: 1

                                )
                              ]
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            provider['name'],
                            style: TextStyle(fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: MediaQuery.of(context).size.width*0.03),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
