import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../../core/bloc/walletBloc/walletBloc.dart';
import '../../core/bloc/walletBloc/walletEvent.dart';
import '../../core/bloc/walletBloc/walletState.dart';
import '../../core/models/walletModels/walletModel.dart';
import '../../core/const/color_const.dart';
import '../../core/const/assets_const.dart';
import '../../core/bloc/appBloc/appBloc.dart';
import '../../core/bloc/appBloc/appState.dart';
import '../widgets/snackBar.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String? upiUrl;
  final UPIIntentLinks?
  upiIntentLinks; // Specific UPI app links from PG response
  final String transactionId;
  final String amount;
  final String? gatewayName;

  const PaymentScreen({
    Key? key,
    required this.paymentUrl,
    this.upiUrl,
    this.upiIntentLinks,
    required this.transactionId,
    required this.amount,
    this.gatewayName,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPolling = true;
  bool _hasNavigated = false;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    // Debug: Print payment URL when screen initializes
    print('=== PaymentScreen INITIALIZED ===');
    print('Payment URL: ${widget.paymentUrl}');
    print('UPI URL: ${widget.upiUrl ?? "Not provided"}');
    print('UPI URL is null: ${widget.upiUrl == null}');
    print('UPI URL isEmpty: ${widget.upiUrl?.isEmpty ?? true}');
    print('UPI URL length: ${widget.upiUrl?.length ?? 0}');
    print(
      'Will show button: ${widget.upiUrl != null && widget.upiUrl!.isNotEmpty}',
    );

    // Log UPI Intent Links (NEW from backend update)
    print('\n=== UPI INTENT LINKS IN PAYMENT SCREEN ===');
    if (widget.upiIntentLinks != null) {
      print('✅ UPI Intent Links available!');
      print('  - BHIM Link: ${widget.upiIntentLinks!.bhimLink ?? "null"}');
      print(
        '  - PhonePe Link: ${widget.upiIntentLinks!.phonepeLink ?? "null"}',
      );
      print('  - Paytm Link: ${widget.upiIntentLinks!.paytmLink ?? "null"}');
      print('  - GPay Link: ${widget.upiIntentLinks!.gpayLink ?? "null"}');
      print('✅ Will use specific app links for direct app opening!');
    } else {
      print('⚠️ UPI Intent Links not available');
      print('⚠️ Will use generic upi_url with method channels');
    }

    print('Payment URL type: ${widget.paymentUrl.runtimeType}');
    print('Payment URL length: ${widget.paymentUrl.length}');
    print('Transaction ID: ${widget.transactionId}');
    print('Amount: ${widget.amount}');

    // Validate payment URL
    if (widget.paymentUrl.isEmpty || widget.paymentUrl.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Payment URL is empty. Please try again.';
        _isLoading = false;
      });
      print('ERROR: Payment URL is empty!');
      return;
    }

    // For Razorpay, open directly in browser (better compatibility)
    final gatewayName = widget.gatewayName?.toLowerCase() ?? '';
    if (gatewayName.contains('razorpay')) {
      print('=== Razorpay gateway detected - opening in browser directly ===');
      Future.microtask(() async {
        try {
          final uri = Uri.parse(widget.paymentUrl);
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            print('✅ Razorpay payment page opened in browser');
            if (mounted) {
              setState(() {
                _errorMessage =
                    'Payment page opened in browser. Complete payment there.';
                _isLoading = false;
              });
            }
            // Show snackbar
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                showSnack(
                  context,
                  'Payment page opened in browser. Complete payment there.',
                );
              }
            });
          } else {
            print('❌ Failed to open browser');
            if (mounted) {
              setState(() {
                _errorMessage = 'Could not open browser. Please try again.';
                _isLoading = false;
              });
            }
          }
        } catch (e) {
          print('❌ Error opening Razorpay in browser: $e');
          if (mounted) {
            setState(() {
              _errorMessage = 'Error opening browser: ${e.toString()}';
              _isLoading = false;
            });
          }
        }
      });
      // Don't initialize WebView for Razorpay - browser handles it
      return;
    }

    // Initialize WebView controller with enhanced settings
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('=== WebView page started ===');
            print('URL: $url');
            print('Timestamp: ${DateTime.now()}');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null; // Clear any previous errors
              });
            }
          },
          onPageFinished: (String url) {
            print('=== WebView page finished ===');
            print('URL: $url');
            print('Timestamp: ${DateTime.now()}');

            // Check if this is a payment success/failure page
            final urlLower = url.toLowerCase();
            if (urlLower.contains('success') ||
                urlLower.contains('payment-success') ||
                urlLower.contains('status=success')) {
              print(
                '✅ Payment success page detected - checking payment status...',
              );
              // Trigger a payment status check
              Future.delayed(Duration(seconds: 1), () {
                if (mounted && _isPolling && !_hasNavigated) {
                  context.read<WalletBloc>().add(
                    CheckPaymentStatus(transactionId: widget.transactionId),
                  );
                }
              });
            } else if (urlLower.contains('failure') ||
                urlLower.contains('payment-failed') ||
                urlLower.contains('status=failed')) {
              print(
                '❌ Payment failure page detected - checking payment status...',
              );
              // Trigger a payment status check
              Future.delayed(Duration(seconds: 1), () {
                if (mounted && _isPolling && !_hasNavigated) {
                  context.read<WalletBloc>().add(
                    CheckPaymentStatus(transactionId: widget.transactionId),
                  );
                }
              });
            }

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print(
              '⚠️ WebView Error: ${error.description} | Code: ${error.errorCode} | URL: ${error.url}',
            );

            // Handle ERR_UNKNOWN_URL_SCHEME - payment gateway redirects to custom schemes
            if (error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
              final failedUrl = error.url ?? '';
              print('⚠️ Unknown URL scheme detected: $failedUrl');

              // Handle UPI URLs
              if (failedUrl.startsWith('upi://') ||
                  failedUrl.startsWith('paytm://') ||
                  failedUrl.startsWith('phonepe://') ||
                  failedUrl.startsWith('gpay://') ||
                  failedUrl.startsWith('tez://')) {
                print('✅ UPI URL detected, launching externally...');
                Future.microtask(() async {
                  try {
                    final uri = Uri.parse(failedUrl);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    print('✅ UPI URL launched successfully');
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  } catch (e) {
                    print('❌ Error launching UPI URL: $e');
                  }
                });
                return;
              }

              // Handle other custom schemes (like truecallersdk://)
              // These can't be handled in WebView - open payment page in browser instead
              if (failedUrl.startsWith('truecallersdk://') ||
                  failedUrl.startsWith('intent://') ||
                  failedUrl.contains('://')) {
                print('⚠️ Custom scheme detected that WebView cannot handle');
                print('⚠️ Opening payment page in external browser instead...');

                if (mounted && error.isForMainFrame == true) {
                  // Open the original payment URL in external browser
                  Future.microtask(() async {
                    try {
                      final uri = Uri.parse(widget.paymentUrl);
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      print('✅ Payment page opened in external browser');
                      if (mounted) {
                        setState(() {
                          _errorMessage =
                              'Payment gateway requires external browser. Payment page opened in browser.';
                          _isLoading = false;
                        });
                      }
                    } catch (e) {
                      print('❌ Error opening payment URL in browser: $e');
                      if (mounted) {
                        setState(() {
                          _errorMessage =
                              'Payment gateway requires external browser.';
                          _isLoading = false;
                        });
                      }
                    }
                  });
                }
                return;
              }
            }

            // For other errors, only show if it's a critical main frame error
            if (error.isForMainFrame == true &&
                (error.errorCode == -2 ||
                    error.errorCode == -6 ||
                    error.errorCode == -8)) {
              print('❌ Critical network error detected');
              if (mounted) {
                setState(() {
                  _errorMessage = 'Network error. Please try again.';
                  _isLoading = false;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('=== WebView Navigation Request ===');
            print('URL: ${request.url}');
            print('Is Main Frame: ${request.isMainFrame}');
            print('Timestamp: ${DateTime.now()}');

            final url = request.url.toLowerCase();

            // Monitor URL changes for payment success/failure detection
            if (request.isMainFrame) {
              // Check for success indicators in URL
              if (url.contains('success') ||
                  url.contains('payment-success') ||
                  url.contains('status=success') ||
                  url.contains('payment_status=success')) {
                print('✅ Payment success detected in URL');
                // Don't prevent navigation, let it load
              } else if (url.contains('failure') ||
                  url.contains('payment-failed') ||
                  url.contains('status=failed') ||
                  url.contains('payment_status=failed')) {
                print('❌ Payment failure detected in URL');
                // Don't prevent navigation, let it load
              }
            }

            // ALLOW ALL NAVIGATION - Don't intercept anything
            // Let WebView handle everything naturally
            // Payment gateways need to redirect freely

            // Intercept custom schemes that WebView cannot handle
            if (url.startsWith('tel:') ||
                url.startsWith('mailto:') ||
                url.startsWith('sms:') ||
                url.startsWith('truecallersdk://') ||
                url.startsWith('intent://')) {
              print(
                '⚠️ Custom scheme detected, preventing WebView navigation: ${request.url}',
              );

              // For truecallersdk and intent schemes, open payment page in browser
              if (url.startsWith('truecallersdk://') ||
                  url.startsWith('intent://')) {
                print(
                  '⚠️ Payment gateway custom scheme - opening in external browser',
                );
                Future.microtask(() async {
                  try {
                    final uri = Uri.parse(widget.paymentUrl);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    print('✅ Payment page opened in external browser');
                    if (mounted) {
                      setState(() {
                        _errorMessage =
                            'Payment gateway requires external browser. Payment page opened.';
                        _isLoading = false;
                      });
                    }
                  } catch (e) {
                    print('❌ Error opening payment URL: $e');
                  }
                });
                return NavigationDecision.prevent;
              }

              // For tel, mailto, sms - launch externally
              Future.microtask(() async {
                try {
                  final uri = Uri.parse(request.url);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  print('❌ Error launching deep link: $e');
                }
              });
              return NavigationDecision.prevent;
            }

            // Allow all other navigation
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load URL after a short delay to ensure WebView is ready
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted && _webViewController != null) {
        try {
          print('=== Loading payment URL in WebView ===');
          print('URL: ${widget.paymentUrl}');
          _webViewController!.loadRequest(Uri.parse(widget.paymentUrl));
        } catch (e) {
          print('Error loading initial URL: $e');
          // Don't show error immediately - wait to see if it loads
        }
      }
    });

    // Set a timeout to show error only if page doesn't load at all
    Future.delayed(Duration(seconds: 10), () {
      if (mounted && _isLoading && _errorMessage == null) {
        print('⚠️ Page taking too long to load, showing error');
        setState(() {
          _errorMessage =
              'Payment page is taking too long to load. Please try again.';
          _isLoading = false;
        });
      }
    });

    // Start checking payment status periodically
    _startStatusPolling();
  }

  void _startStatusPolling() {
    // Check status every 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _isPolling && !_hasNavigated) {
        context.read<WalletBloc>().add(
          CheckPaymentStatus(transactionId: widget.transactionId),
        );
        _startStatusPolling();
      }
    });
  }

  void _stopPolling() {
    _isPolling = false;
  }

  Future<void> _safeReloadWebView() async {
    if (!mounted || _webViewController == null) {
      print('WebView not ready for reload');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Always use loadRequest instead of reload to avoid channel errors
      await _webViewController!.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      print('Error reloading WebView: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to reload payment page. Please try opening in browser.';
          _isLoading = false;
        });
      }
    }
  }

  // Method channel for native UPI app launching
  static const MethodChannel _channel = MethodChannel(
    'com.example.ybs_pay/google_pay',
  );

  Future<void> _launchUPIApp(String packageName, String appName) async {
    try {
      print('=== Launching UPI app: $appName ($packageName) ===');
      print('UPI URL: ${widget.upiUrl}');

      if (widget.upiUrl == null || widget.upiUrl!.isEmpty) {
        showSnack(
          context,
          'UPI URL not available. Please use the QR code above.',
        );
        return;
      }

      String upiUrlString = widget.upiUrl!;
      if (!upiUrlString.startsWith('upi://')) {
        if (upiUrlString.startsWith('pay?')) {
          upiUrlString = 'upi://$upiUrlString';
        } else {
          showSnack(context, 'Invalid UPI URL format.');
          return;
        }
      }

      // Use native method channel for Android
      if (Platform.isAndroid) {
        // METHOD 1: Try to open specific app directly first
        try {
          print('🔵 Trying to open $appName ($packageName) directly...');
          final result = await _channel.invokeMethod('openUPIApp', {
            'upiUrl': upiUrlString,
            'packageName': packageName,
          });

          if (result == true) {
            print('✅ $appName opened successfully');
            return;
          } else {
            print('⚠️ $appName may not be installed or cannot handle UPI URL');
          }
        } catch (e) {
          print('⚠️ Failed to open $appName directly: $e');
        }

        // METHOD 2: Fallback to forced chooser (shows all available UPI apps)
        // This allows user to choose any UPI app if the specific app failed
        try {
          print('🔵 Falling back to UPI app chooser...');
          final chooserResult = await _channel.invokeMethod(
            'openUPIWithChooser',
            {'upiUrl': upiUrlString},
          );

          if (chooserResult == true) {
            print('✅ UPI chooser opened - user can select any UPI app');
            return;
          }
        } catch (e) {
          print('⚠️ Forced chooser method also failed: $e');
        }
      }

      // If both methods failed, show helpful message
      print('⚠️ Both methods failed - UPI apps may not be installed');
      showSnack(
        context,
        'Could not open UPI payment. Please ensure a UPI app (Google Pay, PhonePe, Paytm, etc.) is installed.',
      );
    } catch (e) {
      print('❌ Error launching $appName: $e');
      showSnack(context, 'Could not open payment app. Please try again.');
    }
  }

  Future<void> _openGooglePay() async {
    try {
      print('=== Opening Google Pay ===');

      // Priority 1: Use specific GPay link from PG response if available
      if (widget.upiIntentLinks?.gpayLink != null &&
          widget.upiIntentLinks!.gpayLink!.isNotEmpty) {
        print(
          '✅ Using specific GPay link from PG response: ${widget.upiIntentLinks!.gpayLink}',
        );
        try {
          final uri = Uri.parse(widget.upiIntentLinks!.gpayLink!);
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            print('✅ Google Pay opened successfully using specific link');
            return;
          }
        } catch (e) {
          print('⚠️ Failed to open GPay using specific link: $e');
        }
      }

      // Priority 2: Use generic UPI URL with method channel
      if (widget.upiUrl != null && widget.upiUrl!.isNotEmpty) {
        print('🔵 Using generic UPI URL: ${widget.upiUrl}');
        String upiUrlString = widget.upiUrl!;
        if (!upiUrlString.startsWith('upi://')) {
          if (upiUrlString.startsWith('pay?')) {
            upiUrlString = 'upi://$upiUrlString';
          } else {
            showSnack(context, 'Invalid UPI URL format.');
            return;
          }
        }

        if (Platform.isAndroid) {
          // Use forced chooser (most reliable)
          print('🔵 Using forced chooser for Google Pay...');
          try {
            final result = await _channel.invokeMethod('openUPIWithChooser', {
              'upiUrl': upiUrlString,
            });

            if (result == true) {
              print(
                '✅ UPI chooser opened - Google Pay should be available in the list',
              );
              return;
            }
          } catch (e) {
            print('⚠️ Forced chooser failed: $e');
          }

          // Fallback: Try direct package names
          print('🔵 Fallback: Trying direct package names...');
          final googlePayPackages = [
            'com.google.android.apps.nbu.paisa.user',
            'com.google.android.apps.nfc.payment',
            'com.google.android.apps.walletnfcrel',
          ];

          for (final packageName in googlePayPackages) {
            try {
              final result = await _channel.invokeMethod('openUPIApp', {
                'upiUrl': upiUrlString,
                'packageName': packageName,
              });

              if (result == true) {
                print('✅ Google Pay opened successfully with $packageName');
                return;
              }
            } catch (e) {
              print('⚠️ Direct method failed with $packageName: $e');
            }
          }
        }
      }

      showSnack(
        context,
        'Could not open Google Pay. Please ensure it is installed.',
      );
    } catch (e) {
      print('❌ Error opening Google Pay: $e');
      showSnack(context, 'Could not open Google Pay. Please try again.');
    }
  }

  Future<void> _openPhonePe() async {
    // Priority 1: Use specific PhonePe link from PG response if available
    if (widget.upiIntentLinks?.phonepeLink != null &&
        widget.upiIntentLinks!.phonepeLink!.isNotEmpty) {
      print(
        '✅ Using specific PhonePe link from PG response: ${widget.upiIntentLinks!.phonepeLink}',
      );
      try {
        final uri = Uri.parse(widget.upiIntentLinks!.phonepeLink!);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          print('✅ PhonePe opened successfully using specific link');
          return;
        }
      } catch (e) {
        print('⚠️ Failed to open PhonePe using specific link: $e');
      }
    }

    // Priority 2: Fallback to generic method
    _launchUPIApp('com.phonepe.app', 'PhonePe');
  }

  Future<void> _openPaytm() async {
    // Priority 1: Use specific Paytm link from PG response if available
    if (widget.upiIntentLinks?.paytmLink != null &&
        widget.upiIntentLinks!.paytmLink!.isNotEmpty) {
      print(
        '✅ Using specific Paytm link from PG response: ${widget.upiIntentLinks!.paytmLink}',
      );
      try {
        final uri = Uri.parse(widget.upiIntentLinks!.paytmLink!);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          print('✅ Paytm opened successfully using specific link');
          return;
        }
      } catch (e) {
        print('⚠️ Failed to open Paytm using specific link: $e');
      }
    }

    // Priority 2: Fallback to generic method
    _launchUPIApp('net.one97.paytm', 'Paytm');
  }

  Future<void> _openBHIM() async {
    // Priority 1: Use specific BHIM link from PG response if available
    if (widget.upiIntentLinks?.bhimLink != null &&
        widget.upiIntentLinks!.bhimLink!.isNotEmpty) {
      print(
        '✅ Using specific BHIM link from PG response: ${widget.upiIntentLinks!.bhimLink}',
      );
      try {
        final uri = Uri.parse(widget.upiIntentLinks!.bhimLink!);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          print('✅ BHIM opened successfully using specific link');
          return;
        }
      } catch (e) {
        print('⚠️ Failed to open BHIM using specific link: $e');
      }
    }

    // Priority 2: Fallback to generic method
    _launchUPIApp('in.org.npci.upiapp', 'BHIM');
  }

  // Open UPI chooser - shows all available UPI apps
  Future<void> _openUPIChooser() async {
    try {
      print('=== Opening UPI App Chooser ===');
      print('UPI URL: ${widget.upiUrl}');

      if (widget.upiUrl == null || widget.upiUrl!.isEmpty) {
        showSnack(
          context,
          'UPI URL not available. Please use the QR code above.',
        );
        return;
      }

      String upiUrlString = widget.upiUrl!;
      if (!upiUrlString.startsWith('upi://')) {
        if (upiUrlString.startsWith('pay?')) {
          upiUrlString = 'upi://$upiUrlString';
        } else {
          showSnack(context, 'Invalid UPI URL format.');
          return;
        }
      }

      if (Platform.isAndroid) {
        try {
          print('🔵 Opening UPI chooser (shows all available UPI apps)...');
          final result = await _channel.invokeMethod('openUPIWithChooser', {
            'upiUrl': upiUrlString,
          });

          if (result == true) {
            print('✅ UPI chooser opened successfully');
            return;
          } else {
            print('⚠️ UPI chooser returned false');
          }
        } catch (e) {
          print('⚠️ Failed to open UPI chooser: $e');
        }
      }

      showSnack(
        context,
        'Could not open UPI payment. Please ensure a UPI app is installed.',
      );
    } catch (e) {
      print('❌ Error opening UPI chooser: $e');
      showSnack(context, 'Could not open payment. Please try again.');
    }
  }

  void _showUPIAppBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        double scrWidth = MediaQuery.of(context).size.width;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Title
              Text(
                'Pay with UPI App',
                style: TextStyle(
                  fontSize: scrWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Select your preferred UPI app to complete payment',
                style: TextStyle(
                  fontSize: scrWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              // Google Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openGooglePay();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          AssetsConst.googlePayLogoUPI,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              AssetsConst.googlePayLogo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.account_balance_wallet,
                                  size: 24,
                                  color: Colors.white,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Google Pay',
                          style: TextStyle(
                            fontSize: scrWidth * 0.038,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // PhonePe Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openPhonePe();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          AssetsConst.phonePeLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.payment,
                              size: 24,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'PhonePe',
                          style: TextStyle(
                            fontSize: scrWidth * 0.038,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Paytm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openPaytm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          AssetsConst.paytmLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.account_balance,
                              size: 24,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Paytm',
                          style: TextStyle(
                            fontSize: scrWidth * 0.038,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // BHIM Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openBHIM();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          AssetsConst.bhimLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.mobile_friendly,
                              size: 24,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'BHIM UPI',
                          style: TextStyle(
                            fontSize: scrWidth * 0.038,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Divider
              Divider(height: 1, color: Colors.grey[300]),
              SizedBox(height: 12),
              // Choose UPI App Button (Shows Chooser)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openUPIChooser();
                  },
                  icon: Icon(Icons.apps, size: 20),
                  label: Text(
                    'Choose UPI App',
                    style: TextStyle(
                      fontSize: scrWidth * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Shows all available UPI apps on your device',
                style: TextStyle(
                  fontSize: scrWidth * 0.030,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        print('=== PaymentScreen BlocListener: State Changed ===');
        print('State type: ${state.runtimeType}');
        print('Timestamp: ${DateTime.now()}');

        if (state is PaymentStatusChecked) {
          print(
            '=== PaymentStatusChecked STATE RECEIVED IN PAYMENT SCREEN ===',
          );
          print('Status: ${state.status.status}');
          print('Status Display: ${state.status.statusDisplay}');
          print('Transaction ID: ${state.status.transactionId}');
          print('Amount: ${state.status.amount}');
          print('Current Balance: ${state.status.currentBalance}');
          print('Has Navigated: $_hasNavigated');

          if (state.status.status == 'SUCCESS' && !_hasNavigated) {
            print('✅ Payment SUCCESS detected - navigating back...');
            // Stop polling to prevent multiple navigation attempts
            _stopPolling();
            _hasNavigated = true;

            // Payment successful - defer navigation to avoid Navigator lock
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                print('Navigating back with success=true');
                Navigator.pop(context, true); // Return true to indicate success
                showSnack(context, 'Payment successful! Balance updated.');
                // Refresh balance
                context.read<WalletBloc>().add(FetchWalletBalance());
              } else {
                print('Widget not mounted, skipping navigation');
              }
            });
          } else if (state.status.status == 'FAILED' && !_hasNavigated) {
            print('❌ Payment FAILED detected - navigating back...');
            // Stop polling to prevent multiple navigation attempts
            _stopPolling();
            _hasNavigated = true;

            // Payment failed - defer navigation to avoid Navigator lock
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                print('Navigating back with success=false');
                Navigator.pop(context, false);
                showSnack(context, 'Payment failed. Please try again.');
              } else {
                print('Widget not mounted, skipping navigation');
              }
            });
          } else if (state.status.status == 'PENDING') {
            print('⏳ Payment still PENDING - continuing to poll...');
          } else {
            print('⚠️ Unknown status or already navigated');
            print('Status: ${state.status.status}');
            print('Has Navigated: $_hasNavigated');
          }
        } else if (state is WalletError) {
          print('=== WalletError STATE RECEIVED IN PAYMENT SCREEN ===');
          print('Error message: ${state.message}');
          setState(() {
            _errorMessage = state.message;
          });
        } else {
          print('=== Other State in PaymentScreen: ${state.runtimeType} ===');
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
                    // Center: Title
                    // Expanded(
                    //   child: Center(
                    //     child: Text(
                    //       'Complete Payment',
                    //       style: TextStyle(
                    //         fontSize: scrWidth * 0.033,
                    //         fontWeight: FontWeight.w600,
                    //         color: Colors.grey.shade900,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // // Right: Empty space (for alignment)
                    SizedBox(width: scrWidth * 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Amount info
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 6),
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Amount to Pay    ',
                    style: TextStyle(
                      fontSize: scrWidth * 0.03,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₹${widget.amount}',
                    style: TextStyle(
                      fontSize: scrWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: colorConst.primaryColor1,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),

            // WebView or Error display
            Expanded(
              child: _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Show different icon for browser opened vs error
                            if (_errorMessage!.contains('opened in browser') ||
                                _errorMessage!.contains('Payment page opened'))
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.green,
                              )
                            else
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                            SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: scrWidth * 0.04,
                                color:
                                    _errorMessage!.contains(
                                          'opened in browser',
                                        ) ||
                                        _errorMessage!.contains(
                                          'Payment page opened',
                                        )
                                    ? Colors.green.shade700
                                    : Colors.red,
                              ),
                            ),
                            if (_errorMessage!.contains('opened in browser') ||
                                _errorMessage!.contains('Payment page opened'))
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  'Payment status will be checked automatically.\nYou can close this screen.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: scrWidth * 0.035,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _errorMessage = null;
                                      _isLoading = true;
                                    });
                                    _safeReloadWebView();
                                  },
                                  icon: Icon(Icons.refresh),
                                  label: Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorConst.primaryColor1,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : _webViewController != null
                  ? Stack(
                      children: [
                        // WebView
                        WebViewWidget(controller: _webViewController!),
                        // Loading overlay
                        if (_isLoading)
                          Container(
                            color: Colors.white.withOpacity(0.8),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading payment page...',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
            ),

            // UPI App button - opens bottom sheet
            if (widget.upiUrl != null && widget.upiUrl!.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openUPIChooser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorConst.primaryColor1,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(6),
                              child: Image.asset(
                                AssetsConst.UPILogo,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.account_balance_wallet,
                                    size: 24,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Pay with UPI App',
                              style: TextStyle(
                                fontSize: scrWidth * 0.037,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to select your preferred UPI app',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.orange[700],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'UPI direct payment not available. Please use the QR code above or complete payment in the browser.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
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
    );
  }
}
