import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ybs_pay/View/TransactionDetails/widgets/appbar.dart';
import 'package:ybs_pay/View/TransactionDetails/widgets/details.dart';

import '../receipt/receiptScreen.dart';

class Transaction_page extends StatefulWidget {
  final providerImage;
  final providerText;
  final providernumber;
  final providerrate;
  final providerstatus;
  final providermobilenum;
  final provideroperator;
  final provideramount;
  final providertransid;
  final providerliveid;
  final providerdate;
  final providertime;

  const Transaction_page({
    super.key,

    required this.providerImage,
    required this.providerText,
    required this.providernumber,
    required this.providerrate,
    required this.providerstatus,
    required this.providermobilenum,
    required this.provideroperator,
    required this.provideramount,
    required this.providertransid,
    required this.providerliveid,
    required this.providerdate,
    required this.providertime,
  });

  @override
  State<Transaction_page> createState() => _Transaction_pageState();
}

class _Transaction_pageState extends State<Transaction_page> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBarForTransactionPage(
          providersatus: widget.providerstatus,
          providertransid: widget.providertransid,
        ),

        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionInfoWidget(
                providerImage: widget.providerImage,
                providername: widget.providerText,
                providernum: widget.providernumber,
                providerrate: widget.providerrate,
                providerstatus: widget.providerstatus,
                providermobilenum: widget.providermobilenum,
                provideroperator: widget.provideroperator,
                providerliveid: widget.providerliveid,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Divider(color: Colors.grey.shade200, thickness: 5),
              ),

              // Share Button
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        print(widget.providermobilenum);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => receiptScreen(
                              providernum: widget.providermobilenum,
                              provideroperator: widget.provideroperator,
                              provideramount: widget.provideramount,
                              providertransid: widget.providertransid,
                              providerliveid: widget.providerliveid,
                              providerdate: widget.providerdate,
                              providerstatus: widget.providerstatus,
                            ),
                          ),
                        );
                      },
                      style: ButtonStyle(),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.share, color: Colors.blue[900]),
                          ),
                          const Text(
                            "Share customer receipt",
                            style: TextStyle(color: Colors.cyan, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
