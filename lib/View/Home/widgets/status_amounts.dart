import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// Constructor for the status containers in the app

class statusAmountsBox extends StatelessWidget {
  const statusAmountsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16,bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // height: MediaQuery.of(context).size.width*0.3,
            // width: MediaQuery.of(context).size.width*0.25,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.014),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle),
                  Padding(
                    padding: const EdgeInsets.only(top: 4,bottom: 4),
                    child: Text(
                      "Success",
                      style: TextStyle(fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width*0.028),),
                  ),

                  Text(
                    "₹ 0.00",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width*0.028
                    ),),
                ],
              ),
            ),
          ),
          Container(
            // height: MediaQuery.of(context).size.width*0.3,
            // width: MediaQuery.of(context).size.width*0.25,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.014),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart_outlined),
                  Padding(
                    padding: const EdgeInsets.only(top: 4,bottom: 4),
                    child: Text(
                      "Commission",
                      style: TextStyle(fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width*0.025),),
                  ),

                  Text(
                    "₹ 0.00",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width*0.028
                    ),),
                ],
              ),
            ),
          ),
          Container(
            // height: MediaQuery.of(context).size.width*0.3,
            width: MediaQuery.of(context).size.width*0.25,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.014),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions),
                  Padding(
                    padding: const EdgeInsets.only(top: 4,bottom: 4),
                    child: Text(
                      "Pending",
                      style: TextStyle(fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width*0.028),),
                  ),

                  Text(
                    "₹ 0.00",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width*0.028
                    ),),
                ],
              ),
            ),
          ),
          Container(
            // height: MediaQuery.of(context).size.width*0.3,
            // width: MediaQuery.of(context).size.width*0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.014),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline),
                  Padding(
                    padding: const EdgeInsets.only(top: 4,bottom: 4),
                    child: Text(
                      "Failed",
                      style: TextStyle(fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width*0.028),),
                  ),

                  Text(
                    "₹ 0.00",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width*0.028
                    ),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
