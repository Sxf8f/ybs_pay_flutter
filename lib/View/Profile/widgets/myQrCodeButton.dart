import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/walletBloc/walletBloc.dart';
import '../../../core/repository/walletRepository/walletRepo.dart';
import '../../../main.dart';
import '../../qrCode/myQrCodeScreen.dart';

class myQrCodeButton extends StatelessWidget {
  const myQrCodeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.14,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scrWidth * 0.02),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.shade300,
                blurRadius: 2,
                offset: Offset(3, 3),
                spreadRadius: 1,
              )
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) =>
                        WalletBloc(walletRepository: WalletRepository()),
                    child: const MyQrCodeScreen(),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: scrWidth * 0.04),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Text(
                        'My QR Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: MediaQuery.of(context).size.width * 0.032,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: scrWidth * 0.04),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).iconTheme.color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

