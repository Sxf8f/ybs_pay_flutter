import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/bloc/walletBloc/walletBloc.dart';
import '../../../core/bloc/walletBloc/walletEvent.dart';
import '../../../core/bloc/walletBloc/walletState.dart';
import '../../transferMoney/transferMoneyScreen.dart';
import '../../enterUpiAmount/enterAmountScreen.dart';

class qrCodeScanner extends StatefulWidget {
  const qrCodeScanner({super.key});

  @override
  State<qrCodeScanner> createState() => _qrCodeScannerState();
}

/// QR scanner for YBS_PAY and UPI
class _qrCodeScannerState extends State<qrCodeScanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (listenerContext, state) {
        if (state is QRValidated) {
          if (state.validation.valid && state.validation.recipient != null) {
            // Navigate to transfer money screen
            // TransferMoneyScreen will create its own WalletBloc instance
            Navigator.pushReplacement(
              listenerContext,
              MaterialPageRoute(
                builder: (routeContext) => TransferMoneyScreen(
                  recipient: state.validation.recipient!,
                  qrData: state.validation.recipient != null
                      ? 'YBS_PAY|USER_ID|${state.validation.recipient!.userId}|WALLET_ID|${state.validation.recipient!.walletId}'
                      : null,
                ),
              ),
            );
          } else {
            // Show error
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(
                content: Text(state.validation.message),
                backgroundColor: Colors.red,
              ),
            );
            _scanned = false; // Allow scanning again
          }
        } else if (state is WalletError) {
          ScaffoldMessenger.of(listenerContext).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          _scanned = false; // Allow scanning again
        }
      },
      child: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.first;
          final value = barcode.rawValue;
          
          if (value != null) {
            // Check if it's YBS_PAY QR code
            if (value.startsWith('YBS_PAY|')) {
              _scanned = true;
              cameraController.stop();
              // Validate QR code
              context.read<WalletBloc>().add(ValidateQRRequested(qrData: value));
            }
            // Check if it's UPI QR code (legacy support)
            else if (value.startsWith('upi://')) {
              _scanned = true;
              cameraController.stop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => enterAmountScreen(upiId: value),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
