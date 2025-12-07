import 'package:flutter/material.dart';
import 'package:ybs_pay/core/const/assets_const.dart';

class TransactionInfoWidget extends StatelessWidget {
  final providerImage;
  final providername;
  final providernum;
  final providerrate;
  final providerstatus;
  final providermobilenum;
  final provideroperator;

  const TransactionInfoWidget({
    super.key,
    required this.providerImage,
    required this.providername,
    required this.providernum,
    required this.providerrate,
    required this.providerstatus,
    required this.providermobilenum,
    required this.provideroperator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Transaction Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                providerrate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: providerImage.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          "${AssetsConst.apiBase}${providerImage}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.phone_android,
                              color: Colors.grey[400],
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.phone_android,
                        color: Colors.grey[400],
                        size: 30,
                      ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providername,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Operator",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    providernum,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Mobile Number",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("N/A", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "Live ID",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
