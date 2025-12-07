import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../widgets/toggleIcon.dart';

class doubleFactorApi extends StatelessWidget {
  const doubleFactorApi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16,bottom: 8,left: 16,right: 16),
      child: Container(
        // height: MediaQuery.of(context).size.width*0.3,
        width: MediaQuery.of(context).size.width*1,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.01),
          // color: colorConst.primaryColor,
          // color: Colors.orange.shade600,
          // image: DecorationImage(image: AssetImage(favourites[index]["image"]),fit: BoxFit.fill)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const  EdgeInsets.only(
                left: 20,
                right: 24,
                top: 15,
                bottom: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline,color: Colors.grey,size: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: SizedBox(
                          width: scrWidth*0.55,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Double Factor",
                                style: TextStyle(fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: MediaQuery.of(context).size.width*0.035),),
                              SizedBox(height: 8,),
                              Text(
                                "Enable/Disable double factor to make secure transactions.",
                                style: TextStyle(fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: MediaQuery.of(context).size.width*0.028),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: 20,
                      width: 40,
                      child: ThreeDToggle()),

                ],
              ),
            ),
            // Divider(color: Colors.grey.shade300,),

          ],
        ),
      ),
    );
  }
}
