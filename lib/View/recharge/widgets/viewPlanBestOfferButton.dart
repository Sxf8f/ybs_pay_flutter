import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';


/// constructor for the buttons like view plan, best offer and plan pdf in a container
class viewPlanBestOffer extends StatelessWidget {
  const viewPlanBestOffer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(scrWidth*0.014),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade100,
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
          left: 16,
          right: 16,
          top: 16,
          bottom: 22,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(colorConst.primaryColor3),
                      elevation: WidgetStatePropertyAll(3),
                      // shape: WidgetStatePropertyAll(value)
                    ),
                    child: Text(
                      'View Plan'
                      ,style: TextStyle(
                        fontSize: scrWidth*0.03,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                    ),)),
                ElevatedButton(
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                      elevation: WidgetStatePropertyAll(3),
                      // shape: WidgetStatePropertyAll(value)
                    ),
                    child: Text(
                      'Best Offer'
                      ,style: TextStyle(
                        fontSize: scrWidth*0.03,
                        fontWeight: FontWeight.w500,
                        color: colorConst.primaryColor3
                    ),)),
              ],
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: () {
              },
              child: Container(
                height: 37,
                width: scrWidth*0.7,
                decoration: BoxDecoration(
                  color: colorConst.primaryColor3,
                  borderRadius: BorderRadius.circular(scrWidth*0.06),
                  // borderRadius: BorderRadius.only(topRight: )
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Text('Plan PDF',style: TextStyle(
                        fontSize: scrWidth*0.03,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                    ),),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
