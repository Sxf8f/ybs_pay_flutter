import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/walletBloc/walletBloc.dart';
import '../../core/bloc/walletBloc/walletEvent.dart';
import '../../core/bloc/walletBloc/walletState.dart';
import '../../core/bloc/userBloc/userBloc.dart';
import '../../core/bloc/userBloc/userEvent.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appState.dart';
import '../../core/models/walletModels/walletModel.dart';
import '../../core/repository/walletRepository/walletRepo.dart';
import '../../core/const/color_const.dart';
import '../../core/const/assets_const.dart';
import '../../main.dart';

class TransferMoneyScreen extends StatefulWidget {
  final RecipientInfo recipient;
  final String? qrData;

  const TransferMoneyScreen({super.key, required this.recipient, this.qrData});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _isLoading = false;
  BuildContext?
  _buildContext; // Store build context that has access to UserBloc

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _transferMoney(BuildContext blocContext) {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(
        blocContext,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amountValue = double.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    blocContext.read<WalletBloc>().add(
      TransferMoneyRequested(
        recipientUserId: widget.recipient.userId,
        amount: amount,
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
        qrData: widget.qrData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Store the build context that has access to UserBloc (from root level)
    _buildContext = context;

    return BlocProvider(
      create: (context) => WalletBloc(walletRepository: WalletRepository()),
      child: BlocListener<WalletBloc, WalletState>(
        listener: (listenerContext, state) {
          if (state is TransferMoneySuccess) {
            setState(() {
              _isLoading = false;
            });
            // Refresh UserBloc before showing dialog to update balance
            // Use the stored build context which has access to root-level UserBloc
            if (_buildContext != null) {
              try {
                _buildContext!.read<UserBloc>().add(FetchUserDetailsEvent());
                print(
                  'UserBloc refresh triggered before showing success dialog',
                );
              } catch (e) {
                print('Could not refresh UserBloc: $e');
                // Try from listener context as fallback
                try {
                  listenerContext.read<UserBloc>().add(FetchUserDetailsEvent());
                  print('UserBloc refresh triggered from listener context');
                } catch (e2) {
                  print(
                    'Could not refresh UserBloc from listener context: $e2',
                  );
                }
              }
            }

            // Show success message
            showDialog(
              context: listenerContext,
              builder: (dialogContext) => AlertDialog(
                title: Text(
                  'Transfer Successful',
                  style: TextStyle(
                    fontSize: scrWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount: ₹${state.response.amount}',
                      style: TextStyle(
                        fontSize: scrWidth * 0.033,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To: ${state.response.recipient.userName}',
                      style: TextStyle(
                        fontSize: scrWidth * 0.033,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transaction ID: ${state.response.transactionId}',
                      style: TextStyle(
                        fontSize: scrWidth * 0.029,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your new balance: ₹${state.response.sender.newBalance}',
                      style: TextStyle(
                        fontSize: scrWidth * 0.033,
                        fontWeight: FontWeight.w600,
                        color: colorConst.primaryColor1,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close dialog

                      // Refresh UserBloc before navigating back
                      if (_buildContext != null) {
                        try {
                          _buildContext!.read<UserBloc>().add(
                            FetchUserDetailsEvent(),
                          );
                          print('UserBloc refresh triggered before navigation');
                        } catch (e) {
                          print('Could not refresh UserBloc: $e');
                        }
                      }

                      // Navigate back
                      Navigator.of(listenerContext).pop();

                      // Refresh again after a delay to ensure balance updates on home screen
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_buildContext != null && mounted) {
                          try {
                            _buildContext!.read<UserBloc>().add(
                              FetchUserDetailsEvent(),
                            );
                            print(
                              'UserBloc refresh triggered after navigation delay',
                            );
                          } catch (e) {
                            print('Could not refresh UserBloc after delay: $e');
                          }
                        }
                      });
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: scrWidth * 0.033,
                        fontWeight: FontWeight.w600,
                        color: colorConst.primaryColor1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is WalletError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
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
                            buildWhen: (previous, current) =>
                                current is AppLoaded,
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
          body: Column(
            children: [
              // Title section below AppBar
              Container(
                padding: EdgeInsets.only(bottom: 12),
                color: Colors.white,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorConst.primaryColor1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorConst.primaryColor1.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Transfer Money',
                      style: TextStyle(
                        fontSize: scrWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        color: colorConst.primaryColor1,
                      ),
                    ),
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipient Info Card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recipient Details',
                                style: TextStyle(
                                  fontSize: scrWidth * 0.033,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: colorConst.primaryColor1,
                                    child: Text(
                                      widget.recipient.userName.isNotEmpty
                                          ? widget.recipient.userName[0]
                                                .toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.recipient.userName,
                                          style: TextStyle(
                                            fontSize: scrWidth * 0.033,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.recipient.phone,
                                          style: TextStyle(
                                            fontSize: scrWidth * 0.029,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amount Input
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: scrWidth * 0.033,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: scrWidth * 0.033,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          hintStyle: TextStyle(
                            fontSize: scrWidth * 0.029,
                            color: Colors.grey[500],
                          ),
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(
                            fontSize: scrWidth * 0.033,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Remarks Input
                      Text(
                        'Remarks (Optional)',
                        style: TextStyle(
                          fontSize: scrWidth * 0.033,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _remarksController,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: scrWidth * 0.029,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)',
                          hintStyle: TextStyle(
                            fontSize: scrWidth * 0.029,
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Transfer Button
                      Builder(
                        builder: (buttonContext) => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _transferMoney(buttonContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorConst.primaryColor1,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Transfer Money',
                                    style: TextStyle(
                                      fontSize: scrWidth * 0.033,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
