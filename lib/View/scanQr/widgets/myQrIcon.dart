import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/walletBloc/walletBloc.dart';
import '../../../core/repository/walletRepository/walletRepo.dart';
import '../../qrCode/myQrCodeScreen.dart';
import '../../../main.dart';

/// My QR Code icon in the qr scanner screen
class myQrIcon extends StatelessWidget {
  const myQrIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 20,
      child: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(scrWidth * 0.02),
          ),
          child: Icon(
            Icons.qr_code_2,
            color: Colors.white,
            size: 28,
          ),
        ),
        onPressed: () {
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
      ),
    );
  }
}

