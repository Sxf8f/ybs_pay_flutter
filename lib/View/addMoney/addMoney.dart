import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/View/Home/widgets/home_app_bar.dart';
import 'package:ybs_pay/View/addMoney/widgets/amount.dart';
import 'package:ybs_pay/View/addMoney/widgets/walletType.dart';
import 'package:ybs_pay/View/addMoney/paymentScreen.dart';
import 'package:ybs_pay/core/bloc/walletBloc/walletBloc.dart';
import 'package:ybs_pay/core/bloc/walletBloc/walletEvent.dart';
import 'package:ybs_pay/core/bloc/walletBloc/walletState.dart';
import 'package:ybs_pay/core/repository/walletRepository/walletRepo.dart';
import 'package:ybs_pay/core/const/color_const.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/core/models/walletModels/walletModel.dart';
import 'package:ybs_pay/main.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/snackBar.dart';

class addMoneyScreen extends StatefulWidget {
  const addMoneyScreen({super.key});

  @override
  State<addMoneyScreen> createState() => _addMoneyScreenState();
}

class _addMoneyScreenState extends State<addMoneyScreen> {
  TextEditingController? _amountController;
  bool _isLoading = false;
  WalletBalanceResponse? _cachedBalance;
  PaymentMethod? _selectedPaymentMethod;
  PaymentMethodsResponse? _paymentMethodsResponse;
  WalletBloc? _walletBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = WalletBloc(walletRepository: WalletRepository());
        // Store reference to bloc for later use
        _walletBloc = bloc;
        // Always fetch balance when screen opens
        bloc.add(FetchWalletBalance());
        // Fetch payment methods after a short delay to let balance load first
        Future.delayed(Duration(milliseconds: 200), () {
          if (bloc.isClosed == false) {
            bloc.add(FetchPaymentMethods());
          }
        });
        return bloc;
      },
      child: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          print('=== BlocListener: State Changed ===');
          print('State type: ${state.runtimeType}');
          print('Timestamp: ${DateTime.now()}');

          if (state is AddMoneySuccess) {
            print('=== AddMoneySuccess STATE RECEIVED ===');
            print('Response details:');
            print('  - Success: ${state.response.success}');
            print('  - Message: ${state.response.message}');
            print('  - Transaction ID: ${state.response.transactionId}');
            print('  - Payment URL: ${state.response.paymentUrl ?? "null"}');
            print('  - Redirect: ${state.response.redirect}');
            print('  - Amount: ${state.response.amount}');

            setState(() {
              _isLoading = false;
            });
            print('Loading state set to false');

            if (state.response.redirect && state.response.paymentUrl != null) {
              print('Redirecting to payment screen...');
              print('Payment URL: ${state.response.paymentUrl}');
              print('Transaction ID: ${state.response.transactionId}');

              // Navigate to payment screen
              Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<WalletBloc>(),
                        child: PaymentScreen(
                          paymentUrl: state.response.paymentUrl!,
                          upiUrl: state.response.upiUrl,
                          upiIntentLinks: state
                              .response
                              .upiIntentLinks, // Pass specific UPI app links
                          transactionId: state.response.transactionId,
                          amount: state.response.amount,
                          gatewayName:
                              state.response.gatewayName, // Pass gateway name
                        ),
                      ),
                    ),
                  )
                  .then((success) {
                    print('Payment screen returned with success: $success');
                    if (success == true) {
                      print('Refreshing wallet balance...');
                      // Refresh balance after successful payment
                      context.read<WalletBloc>().add(FetchWalletBalance());
                    }
                  })
                  .catchError((error) {
                    print('ERROR navigating to payment screen: $error');
                  });
            } else {
              print('No redirect needed (admin direct add)');
              // Admin direct add - no redirect needed
              showSnack(context, state.response.message);
              context.read<WalletBloc>().add(FetchWalletBalance());
            }
          } else if (state is WalletError) {
            print('=== WalletError STATE RECEIVED ===');
            print('Error message: ${state.message}');
            print('Error message length: ${state.message.length}');

            setState(() {
              _isLoading = false;
            });
            print('Loading state set to false');

            // Show error message for wallet errors
            final errorMsg = state.message;
            print('Processing error message...');

            if (errorMsg.contains('Authentication') ||
                errorMsg.contains('token') ||
                errorMsg.contains('login')) {
              print('Authentication error detected');
              showSnack(
                context,
                'Please login again. Your session may have expired.',
              );
            } else {
              print('Showing generic error message');
              showSnack(context, errorMsg);
            }
          } else if (state is WalletLoading) {
            print('=== WalletLoading STATE RECEIVED ===');
            print('Still loading...');
          } else {
            print('=== Other State: ${state.runtimeType} ===');
          }
        },
        child: BlocListener<WalletBloc, WalletState>(
          listener: (context, state) {
            // Cache balance when it's loaded
            if (state is WalletBalanceLoaded) {
              setState(() {
                _cachedBalance = state.balance;
              });
            }
            // Cache payment methods when loaded
            if (state is PaymentMethodsLoaded) {
              setState(() {
                _paymentMethodsResponse = state.paymentMethods;
                // Don't auto-select - let user choose in dialog
              });
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: HomeAppBar(
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            body: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                final isLoading = state is WalletLoading || _isLoading;
                final isInitialLoading =
                    state is WalletInitial ||
                    (state is WalletLoading && _cachedBalance == null);

                if (isInitialLoading) {
                  return _buildSkeletonLoader();
                }

                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: scrWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: scrWidth * 0.05),

                        // Header Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Money',
                              style: TextStyle(
                                fontSize: scrWidth * 0.033,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: scrWidth * 0.01),
                            Text(
                              'Add funds to your wallet',
                              style: TextStyle(
                                fontSize: scrWidth * 0.028,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: scrWidth * 0.05),

                        /// Wallet type and balance - Redesigned
                        walletType(cachedBalance: _cachedBalance),

                        SizedBox(height: scrWidth * 0.05),

                        /// Enter amount - Redesigned
                        enterAmount(
                          onControllerCreated: (controller) {
                            _amountController = controller;
                          },
                        ),

                        SizedBox(height: scrWidth * 0.06),

                        /// Proceed to Payment Button (shows dialog for payment method selection)
                        _buildProceedToPaymentButton(isLoading),

                        SizedBox(height: scrWidth * 0.05),

                        SizedBox(height: scrWidth * 0.05),

                        // Charge Calculation Preview
                        if (_selectedPaymentMethod != null &&
                            _amountController?.text.isNotEmpty == true)
                          _buildChargePreview(),

                        SizedBox(height: scrWidth * 0.05),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProceedToPaymentButton(bool isLoading) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                print('=== PROCEED TO PAYMENT BUTTON CLICKED ===');
                print('Timestamp: ${DateTime.now()}');

                // Validate amount first
                final amount = _amountController?.text.trim() ?? '';
                if (amount.isEmpty) {
                  showSnack(context, 'Please enter an amount');
                  return;
                }

                final amountValue = double.tryParse(amount);
                if (amountValue == null || amountValue <= 0) {
                  showSnack(context, 'Please enter a valid amount');
                  return;
                }

                // Show payment method selection dialog
                _showPaymentMethodDialog(context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorConst.primaryColor1,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: scrWidth * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: scrWidth * 0.05,
                width: scrWidth * 0.05,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: scrWidth * 0.033),
                  SizedBox(width: scrWidth * 0.015),
                  Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: scrWidth * 0.033,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    print('=== SHOWING PAYMENT METHOD DIALOG ===');

    if (_paymentMethodsResponse == null) {
      showSnack(context, 'Payment methods are loading. Please wait...');
      return;
    }

    if (_paymentMethodsResponse!.paymentMethods.isEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'No Payment Methods',
            style: TextStyle(
              fontSize: scrWidth * 0.033,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            _paymentMethodsResponse!.message ??
                'No payment methods are currently available.',
            style: TextStyle(
              fontSize: scrWidth * 0.029,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Store selected method in dialog state
    PaymentMethod? dialogSelectedMethod = _selectedPaymentMethod;

    // Filter out upi_intent and ppi_wallet
    final filteredMethods = _paymentMethodsResponse!.paymentMethods
        .where(
          (method) =>
              method.operator != 'upi_intent' &&
              method.operator != 'ppi_wallet',
        )
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: scrWidth * 0.033,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Builder(
            builder: (contentContext) {
              // Find UPI Collect method
              PaymentMethod? upiMethod;
              try {
                upiMethod = filteredMethods.firstWhere(
                  (method) => method.operator == 'upi_collect',
                );
              } catch (e) {
                upiMethod = null;
              }

              // Find Net Banking, Credit Card, or Debit Card methods
              final cardMethods = filteredMethods
                  .where(
                    (method) =>
                        method.operator == 'net_banking' ||
                        method.operator == 'credit_card' ||
                        method.operator == 'debit_card',
                  )
                  .toList();

              // Get Net Banking method for charge info (prioritize net_banking)
              PaymentMethod? netBankingMethod;
              if (cardMethods.isNotEmpty) {
                try {
                  netBankingMethod = cardMethods.firstWhere(
                    (method) => method.operator == 'net_banking',
                  );
                } catch (e) {
                  netBankingMethod = cardMethods.first;
                }
              }

              // If no methods available, show message
              if (upiMethod == null && cardMethods.isEmpty) {
                return Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(vertical: scrWidth * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: scrWidth * 0.12,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: scrWidth * 0.04),
                      Text(
                        'Sorry, no payment method found',
                        style: TextStyle(
                          fontSize: scrWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: scrWidth * 0.02),
                      Text(
                        'Contact customer care',
                        style: TextStyle(
                          fontSize: scrWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Show two icon buttons with charge details
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Buttons Row
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: scrWidth * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // UPI Button
                        if (upiMethod != null)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                print('=== UPI BUTTON CLICKED IN DIALOG ===');
                                setDialogState(() {
                                  dialogSelectedMethod = upiMethod;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: scrWidth * 0.02,
                                ),
                                padding: EdgeInsets.all(scrWidth * 0.04),
                                decoration: BoxDecoration(
                                  color:
                                      dialogSelectedMethod?.operator ==
                                          'upi_collect'
                                      ? colorConst.primaryColor1.withOpacity(
                                          0.08,
                                        )
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        dialogSelectedMethod?.operator ==
                                            'upi_collect'
                                        ? colorConst.primaryColor1
                                        : Colors.grey.shade300,
                                    width:
                                        dialogSelectedMethod?.operator ==
                                            'upi_collect'
                                        ? 2
                                        : 1,
                                  ),
                                  boxShadow:
                                      dialogSelectedMethod?.operator ==
                                          'upi_collect'
                                      ? [
                                          BoxShadow(
                                            color: colorConst.primaryColor1
                                                .withOpacity(0.15),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                            spreadRadius: 0,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(scrWidth * 0.02),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.asset(
                                        AssetsConst.upiLogo,
                                        height: scrWidth * 0.12,
                                        width: scrWidth * 0.12,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.account_balance_wallet,
                                                size: scrWidth * 0.08,
                                                color:
                                                    dialogSelectedMethod
                                                            ?.operator ==
                                                        'upi_collect'
                                                    ? colorConst.primaryColor1
                                                    : Colors.grey[700],
                                              );
                                            },
                                      ),
                                    ),
                                    if (dialogSelectedMethod?.operator ==
                                        'upi_collect')
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: scrWidth * 0.01,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: scrWidth * 0.04,
                                          color: colorConst.primaryColor1,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Card/Net Banking Button
                        if (netBankingMethod != null)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                print(
                                  '=== CARD/NET BANKING BUTTON CLICKED IN DIALOG ===',
                                );
                                // Select net_banking (or first available from the three)
                                final selectedMethod = cardMethods.firstWhere(
                                  (method) => method.operator == 'net_banking',
                                  orElse: () => cardMethods.first,
                                );
                                setDialogState(() {
                                  dialogSelectedMethod = selectedMethod;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: scrWidth * 0.02,
                                ),
                                padding: EdgeInsets.all(scrWidth * 0.04),
                                decoration: BoxDecoration(
                                  color:
                                      (dialogSelectedMethod?.operator ==
                                              'net_banking' ||
                                          dialogSelectedMethod?.operator ==
                                              'credit_card' ||
                                          dialogSelectedMethod?.operator ==
                                              'debit_card')
                                      ? colorConst.primaryColor1.withOpacity(
                                          0.08,
                                        )
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        (dialogSelectedMethod?.operator ==
                                                'net_banking' ||
                                            dialogSelectedMethod?.operator ==
                                                'credit_card' ||
                                            dialogSelectedMethod?.operator ==
                                                'debit_card')
                                        ? colorConst.primaryColor1
                                        : Colors.grey.shade300,
                                    width:
                                        (dialogSelectedMethod?.operator ==
                                                'net_banking' ||
                                            dialogSelectedMethod?.operator ==
                                                'credit_card' ||
                                            dialogSelectedMethod?.operator ==
                                                'debit_card')
                                        ? 2
                                        : 1,
                                  ),
                                  boxShadow:
                                      (dialogSelectedMethod?.operator ==
                                              'net_banking' ||
                                          dialogSelectedMethod?.operator ==
                                              'credit_card' ||
                                          dialogSelectedMethod?.operator ==
                                              'debit_card')
                                      ? [
                                          BoxShadow(
                                            color: colorConst.primaryColor1
                                                .withOpacity(0.15),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                            spreadRadius: 0,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(scrWidth * 0.02),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.asset(
                                        AssetsConst.debitCardLogo,
                                        height: scrWidth * 0.12,
                                        width: scrWidth * 0.12,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.account_balance,
                                                size: scrWidth * 0.08,
                                                color:
                                                    (dialogSelectedMethod
                                                                ?.operator ==
                                                            'net_banking' ||
                                                        dialogSelectedMethod
                                                                ?.operator ==
                                                            'credit_card' ||
                                                        dialogSelectedMethod
                                                                ?.operator ==
                                                            'debit_card')
                                                    ? colorConst.primaryColor1
                                                    : Colors.grey[700],
                                              );
                                            },
                                      ),
                                    ),
                                    if (dialogSelectedMethod?.operator ==
                                            'net_banking' ||
                                        dialogSelectedMethod?.operator ==
                                            'credit_card' ||
                                        dialogSelectedMethod?.operator ==
                                            'debit_card')
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: scrWidth * 0.01,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: scrWidth * 0.04,
                                          color: colorConst.primaryColor1,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Charge Details Section
                  if (dialogSelectedMethod != null)
                    Builder(
                      builder: (detailsContext) {
                        ChargeInfo? chargeInfo;
                        if (dialogSelectedMethod!.operator == 'net_banking' ||
                            dialogSelectedMethod!.operator == 'credit_card' ||
                            dialogSelectedMethod!.operator == 'debit_card') {
                          // Use net_banking's charge info for card methods
                          chargeInfo = netBankingMethod?.chargeInfo;
                        } else {
                          // Use UPI's own charge info
                          chargeInfo = upiMethod?.chargeInfo;
                        }

                        if (chargeInfo == null) {
                          return SizedBox.shrink();
                        }

                        return Container(
                          margin: EdgeInsets.only(top: scrWidth * 0.04),
                          padding: EdgeInsets.all(scrWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Details',
                                style: TextStyle(
                                  fontSize: scrWidth * 0.033,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[900],
                                ),
                              ),
                              SizedBox(height: scrWidth * 0.02),
                              _buildDetailRow(
                                'Charge',
                                chargeInfo.chargeDisplay,
                                Icons.payments_outlined,
                              ),
                              SizedBox(height: scrWidth * 0.015),
                              _buildDetailRow(
                                'Charge Type',
                                chargeInfo.isFixed ? 'Fixed' : 'Percentage',
                                Icons.info_outline,
                              ),
                              SizedBox(height: scrWidth * 0.015),
                              _buildDetailRow(
                                'Min Amount',
                                chargeInfo.minAmountDisplay,
                                Icons.arrow_downward,
                              ),
                              SizedBox(height: scrWidth * 0.015),
                              _buildDetailRow(
                                'Max Amount',
                                chargeInfo.maxAmountDisplay,
                                Icons.arrow_upward,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: scrWidth * 0.029,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed:
                  (dialogSelectedMethod == null || filteredMethods.isEmpty)
                  ? null
                  : () {
                      print('=== PAY BUTTON CLICKED IN DIALOG ===');
                      print(
                        'Selected Payment Method: ${dialogSelectedMethod!.operatorDisplay}',
                      );
                      setState(() {
                        _selectedPaymentMethod = dialogSelectedMethod;
                      });
                      Navigator.pop(dialogContext);
                      // Proceed with payment
                      _handleAddMoney(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorConst.primaryColor1,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: scrWidth * 0.05,
                  vertical: scrWidth * 0.03,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Pay',
                style: TextStyle(
                  fontSize: scrWidth * 0.033,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargePreview() {
    final amount = _amountController?.text.trim() ?? '';
    final amountValue = double.tryParse(amount);

    if (amountValue == null ||
        amountValue <= 0 ||
        _selectedPaymentMethod == null) {
      return SizedBox.shrink();
    }

    // For card methods (net_banking, credit_card, debit_card), use net_banking's charge info
    ChargeInfo? chargeInfo;
    if (_selectedPaymentMethod!.operator == 'net_banking' ||
        _selectedPaymentMethod!.operator == 'credit_card' ||
        _selectedPaymentMethod!.operator == 'debit_card') {
      // Find net_banking method to use its charge info
      if (_paymentMethodsResponse != null) {
        try {
          final netBankingMethod = _paymentMethodsResponse!.paymentMethods
              .firstWhere((method) => method.operator == 'net_banking');
          chargeInfo = netBankingMethod.chargeInfo;
        } catch (e) {
          // If net_banking not found, try to find any of the three
          try {
            final cardMethod = _paymentMethodsResponse!.paymentMethods
                .firstWhere(
                  (method) =>
                      method.operator == 'net_banking' ||
                      method.operator == 'credit_card' ||
                      method.operator == 'debit_card',
                );
            chargeInfo = cardMethod.chargeInfo;
          } catch (e2) {
            // Fallback to selected method's charge info
            chargeInfo = _selectedPaymentMethod!.chargeInfo;
          }
        }
      } else {
        chargeInfo = _selectedPaymentMethod!.chargeInfo;
      }
    } else {
      // For UPI and other methods, use their own charge info
      chargeInfo = _selectedPaymentMethod!.chargeInfo;
    }

    if (chargeInfo == null) {
      return SizedBox.shrink();
    }

    // Calculate charge
    double charge = 0.0;
    if (chargeInfo.isFixed) {
      charge = chargeInfo.charge;
    } else {
      charge = (amountValue * chargeInfo.charge) / 100;
    }

    final netAmount = amountValue - charge;

    // Validate amount range
    final isValidAmount =
        amountValue >= chargeInfo.minAmount &&
        amountValue <= chargeInfo.maxAmount;

    return Container(
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: isValidAmount ? Colors.white : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValidAmount ? Colors.grey.shade200 : Colors.orange.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValidAmount
                    ? Icons.info_outline
                    : Icons.warning_amber_rounded,
                color: isValidAmount ? Colors.green[700] : Colors.orange[700],
                size: scrWidth * 0.04,
              ),
              SizedBox(width: scrWidth * 0.02),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: scrWidth * 0.033,
                  fontWeight: FontWeight.w600,
                  color: isValidAmount ? Colors.green[900] : Colors.orange[900],
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.03),
          if (!isValidAmount) ...[
            Text(
              amountValue < chargeInfo.minAmount
                  ? 'Amount is below minimum (${chargeInfo.minAmountDisplay})'
                  : 'Amount exceeds maximum (${chargeInfo.maxAmountDisplay})',
              style: TextStyle(
                fontSize: scrWidth * 0.028,
                color: Colors.orange[900],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: scrWidth * 0.02),
          ],
          _buildSummaryRow(
            'Amount to Pay',
            '₹${amountValue.toStringAsFixed(2)}',
          ),
          SizedBox(height: scrWidth * 0.015),
          _buildSummaryRow(
            'Processing Charge',
            '₹${charge.toStringAsFixed(2)} (${chargeInfo.chargeType})',
          ),
          SizedBox(height: scrWidth * 0.015),
          Divider(color: Colors.grey[300]),
          SizedBox(height: scrWidth * 0.015),
          _buildSummaryRow(
            'Net Amount Added',
            '₹${netAmount.toStringAsFixed(2)}',
            isBold: true,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: scrWidth * 0.029,
            color: Colors.grey[700],
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: scrWidth * 0.033,
            color: isHighlight ? colorConst.primaryColor1 : Colors.grey[900],
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: scrWidth * 0.029, color: Colors.grey[600]),
        SizedBox(width: scrWidth * 0.02),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: scrWidth * 0.029,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: scrWidth * 0.029,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddMoney(BuildContext context) async {
    print('=== _handleAddMoney CALLED ===');
    print('Timestamp: ${DateTime.now()}');

    final amount = _amountController?.text.trim() ?? '';
    print('Amount from controller: "$amount"');

    if (amount.isEmpty) {
      print('ERROR: Amount is empty');
      showSnack(context, 'Please enter an amount');
      return;
    }

    if (_selectedPaymentMethod == null) {
      print('ERROR: No payment method selected');
      showSnack(context, 'Please select a payment method');
      return;
    }

    print('Selected Payment Method:');
    print('  - Operator: ${_selectedPaymentMethod!.operator}');
    print('  - Display: ${_selectedPaymentMethod!.operatorDisplay}');
    print('  - Gateway: ${_selectedPaymentMethod!.gatewayName}');

    final amountValue = double.tryParse(amount);
    print('Parsed amount value: $amountValue');

    if (amountValue == null || amountValue <= 0) {
      print('ERROR: Invalid amount value');
      showSnack(context, 'Please enter a valid amount');
      return;
    }

    // Validate against payment method limits
    final chargeInfo = _selectedPaymentMethod!.chargeInfo;
    print('Charge Info: ${chargeInfo != null ? "Available" : "Not available"}');

    if (chargeInfo != null) {
      print('  - Min Amount: ${chargeInfo.minAmount}');
      print('  - Max Amount: ${chargeInfo.maxAmount}');
      print('  - Charge: ${chargeInfo.charge} (${chargeInfo.chargeType})');

      if (amountValue < chargeInfo.minAmount) {
        print('ERROR: Amount below minimum');
        showSnack(
          context,
          'Minimum amount for ${_selectedPaymentMethod!.operatorDisplay} is ${chargeInfo.minAmountDisplay}',
        );
        return;
      }

      if (amountValue > chargeInfo.maxAmount) {
        print('ERROR: Amount above maximum');
        showSnack(
          context,
          'Maximum amount for ${_selectedPaymentMethod!.operatorDisplay} is ${chargeInfo.maxAmountDisplay}',
        );
        return;
      }
    }

    print('Validation passed, proceeding to payment...');

    print('Setting loading state to true...');
    setState(() {
      _isLoading = true;
    });

    final formattedAmount = amountValue.toStringAsFixed(2);
    print('=== DISPATCHING AddMoneyRequested EVENT ===');
    print('Amount: $formattedAmount');
    print('Operator: ${_selectedPaymentMethod!.operator}');
    print('Timestamp: ${DateTime.now()}');

    // Get WalletBloc reference - use stored reference or try to get from context
    WalletBloc? walletBloc;
    if (_walletBloc != null && !_walletBloc!.isClosed) {
      walletBloc = _walletBloc;
      print('Using stored WalletBloc reference');
    } else {
      try {
        walletBloc = context.read<WalletBloc>();
        print('Retrieved WalletBloc from context');
      } catch (e) {
        print('ERROR: Could not get WalletBloc from context: $e');
        setState(() {
          _isLoading = false;
        });
        showSnack(
          context,
          'Error: Unable to access payment service. Please try again.',
        );
        return;
      }
    }

    // Call add money API with selected payment method operator
    if (walletBloc != null && !walletBloc.isClosed) {
      try {
        print('Dispatching AddMoneyRequested event to WalletBloc...');
        walletBloc.add(
          AddMoneyRequested(
            amount: formattedAmount,
            operator: _selectedPaymentMethod!.operator,
            secureKey: null,
          ),
        );
        print('AddMoneyRequested event dispatched successfully');
      } catch (e, stackTrace) {
        print('ERROR dispatching AddMoneyRequested event: $e');
        print('Stack trace: $stackTrace');
        setState(() {
          _isLoading = false;
        });
        showSnack(context, 'Error initiating payment: $e');
      }
    } else {
      print('ERROR: WalletBloc is null or closed');
      setState(() {
        _isLoading = false;
      });
      showSnack(
        context,
        'Error: Payment service unavailable. Please try again.',
      );
    }
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scrWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: scrWidth * 0.05),
            // Header skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: scrWidth * 0.05,
                    width: scrWidth * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.01),
                  Container(
                    height: scrWidth * 0.03,
                    width: scrWidth * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: scrWidth * 0.06),
            // Wallet balance skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: scrWidth * 0.035,
                    width: scrWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.03),
                  Container(
                    height: scrWidth * 0.2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(scrWidth * 0.02),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: scrWidth * 0.05),
            // Amount input skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: scrWidth * 0.035,
                    width: scrWidth * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.03),
                  Container(
                    height: scrWidth * 0.12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(scrWidth * 0.02),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: scrWidth * 0.06),
            // Button skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: scrWidth * 0.12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                ),
              ),
            ),
            SizedBox(height: scrWidth * 0.05),
            // Info card skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: scrWidth * 0.15,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
