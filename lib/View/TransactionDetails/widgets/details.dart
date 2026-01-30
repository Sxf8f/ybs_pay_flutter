import 'package:flutter/material.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/core/const/color_const.dart';
import '../../../main.dart';

class TransactionInfoWidget extends StatelessWidget {
  final providerImage;
  final providername;
  final providernum;
  final providerrate;
  final providerstatus;
  final providermobilenum;
  final provideroperator;
  final providerliveid;

  const TransactionInfoWidget({
    super.key,
    required this.providerImage,
    required this.providername,
    required this.providernum,
    required this.providerrate,
    required this.providerstatus,
    required this.providermobilenum,
    required this.provideroperator,
    required this.providerliveid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transaction Details",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: scrWidth * 0.035,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                providerrate,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: scrWidth * 0.038,
                  color: colorConst.primaryColor1,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey[200],
                ),
                child: providerImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "${AssetsConst.apiBase}${providerImage}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.phone_android,
                              color: Colors.grey[400],
                              size: 24,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.phone_android,
                        color: Colors.grey[400],
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providername,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth * 0.035,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Operator",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: scrWidth * 0.025,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providernum,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth * 0.035,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Mobile Number",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: scrWidth * 0.025,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (providerliveid != null &&
                            providerliveid.toString().isNotEmpty &&
                            providerliveid.toString() != 'null')
                        ? providerliveid.toString()
                        : "N/A",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth * 0.035,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Live ID",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: scrWidth * 0.025,
                    ),
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
