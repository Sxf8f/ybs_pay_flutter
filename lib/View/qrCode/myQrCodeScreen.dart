import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/bloc/walletBloc/walletBloc.dart';
import '../../core/bloc/walletBloc/walletEvent.dart';
import '../../core/bloc/walletBloc/walletState.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appState.dart';
import '../../core/const/color_const.dart';
import '../../core/const/assets_const.dart';
import '../../main.dart';

class MyQrCodeScreen extends StatefulWidget {
  const MyQrCodeScreen({super.key});

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch QR code when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletBloc>().add(GenerateQRRequested());
    });
  }

  void _shareQRCode(String qrData) {
    Share.share(
      'Scan this QR code to receive money via TRV Pay\n\n$qrData',
      subject: 'My TRV Pay QR Code',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Back arrow + Logo
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Logo from AppBloc
                      BlocBuilder<AppBloc, AppState>(
                        buildWhen: (previous, current) => current is AppLoaded,
                        builder: (context, state) {
                          String? logoPath;
                          if (state is AppLoaded &&
                              state.settings?.logo != null) {
                            logoPath =
                                "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                          }
                          return Container(
                            height: scrWidth * 0.05,
                            child: logoPath != null && logoPath.isNotEmpty
                                ? Image.network(
                                    logoPath,
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox.shrink();
                                    },
                                  )
                                : SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                  // Right: Empty space
                  SizedBox(width: scrWidth * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QRCodeGenerated) {
            final qrCode = state.qrCode;
            return SingleChildScrollView(
              padding: EdgeInsets.all(scrWidth * 0.04),
              child: Column(
                children: [
                  // User Info Card
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(scrWidth * 0.01),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(scrWidth * 0.04),
                      child: Row(
                        children: [
                          // Profile Circle Icon
                          CircleAvatar(
                            radius: scrWidth * 0.06,
                            backgroundColor: colorConst.primaryColor1,
                            child: Text(
                              qrCode.userName.isNotEmpty
                                  ? qrCode.userName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scrWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: scrWidth * 0.04),
                          // Name and Number
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  qrCode.userName,
                                  style: TextStyle(
                                    fontSize: scrWidth * 0.034,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: scrWidth * 0.01),
                                Text(
                                  qrCode.userPhone,
                                  style: TextStyle(
                                    fontSize: scrWidth * 0.028,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.04),

                  // QR Code Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(scrWidth * 0.01),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(scrWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(scrWidth * 0.01),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Scan to Pay',
                            style: TextStyle(
                              fontSize: scrWidth * 0.033,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: scrWidth * 0.04),
                          // QR Code
                          Container(
                            padding: EdgeInsets.all(scrWidth * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                scrWidth * 0.02,
                              ),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: QrImageView(
                              data: qrCode.qrData,
                              version: QrVersions.auto,
                              size: scrWidth * 0.6,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.04),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    height: scrWidth * 0.12,
                    child: ElevatedButton.icon(
                      onPressed: () => _shareQRCode(qrCode.qrData),
                      icon: const Icon(Icons.share),
                      label: Text(
                        'Share QR Code',
                        style: TextStyle(
                          fontSize: scrWidth * 0.033,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorConst.primaryColor1,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(scrWidth * 0.01),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WalletBloc>().add(GenerateQRRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No QR code available'));
          }
        },
      ),
    );
  }
}
