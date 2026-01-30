import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TestPaymentPage extends StatefulWidget {
  const TestPaymentPage({super.key});

  @override
  State<TestPaymentPage> createState() => _TestPaymentPageState();
}

class _TestPaymentPageState extends State<TestPaymentPage> {
  // Sample UPI URL for testing
  final String testUpiUrl = 'upi://pay?pa=test@upi&pn=TestMerchant&am=100&cu=INR&tn=TestPayment';
  
  // Method channel for native Android methods
  static const MethodChannel _channel = MethodChannel('com.example.ybs_pay/google_pay');
  
  // Google Pay package names (multiple variants)
  final List<String> googlePayPackages = [
    'com.google.android.apps.nfc.payment',  // Old Google Wallet/NFC
    'com.google.android.apps.nbu.paisa.user', // Google Pay India
    'com.google.android.apps.walletnfcrel',   // Google Wallet
  ];
  
  // PhonePe package name
  final String phonePePackage = 'com.phonepe.app';
  
  String _lastResult = 'No action taken yet';
  Color _lastResultColor = Colors.grey;
  
  // Installation status
  Map<String, bool> _appInstalledStatus = {};
  bool _isCheckingApps = false;
  String? _foundGooglePayPackage;
  List<String> _googleAppsList = [];
  List<String> _payAppsList = [];
  List<String> _upiHandlersList = [];
  Map<String, String> _googlePayCandidates = {};
  bool _isLoadingDebugInfo = false;

  void _updateResult(String message, {bool isSuccess = false}) {
    setState(() {
      _lastResult = message;
      _lastResultColor = isSuccess ? Colors.green : Colors.red;
    });
    print('📱 RESULT: $message');
  }

  // Check if apps are installed
  Future<void> _checkAppInstallation() async {
    setState(() {
      _isCheckingApps = true;
      _foundGooglePayPackage = null;
    });
    
    print('\n🔍 ========== CHECKING APP INSTALLATION STATUS ==========');
    
    try {
      // First, try to find Google Pay dynamically
      try {
        final foundPackage = await _channel.invokeMethod('findGooglePayPackage');
        if (foundPackage != null && foundPackage is String) {
          _foundGooglePayPackage = foundPackage;
          print('✅ Found Google Pay package: $foundPackage');
          // Mark all Google Pay packages as installed if we found one
          for (String package in googlePayPackages) {
            _appInstalledStatus[package] = true;
          }
        }
      } catch (e) {
        print('⚠️ findGooglePayPackage method not available - $e');
        print('💡 Note: You may need to rebuild the app for native changes to take effect');
      }
      
      // Check Google Pay packages individually
      for (String package in googlePayPackages) {
        try {
          final result = await _channel.invokeMethod('checkAppInstalled', {
            'packageName': package,
          });
          _appInstalledStatus[package] = result == true;
          print('📦 $package: ${result == true ? "✅ INSTALLED" : "❌ NOT INSTALLED"}');
        } catch (e) {
          // If method not implemented, check if we found it dynamically
          if (_foundGooglePayPackage != null) {
            _appInstalledStatus[package] = true;
            print('📦 $package: ✅ INSTALLED (found via dynamic search)');
          } else {
            _appInstalledStatus[package] = false;
            print('📦 $package: ⚠️ Method not available - $e');
            print('💡 Note: Rebuild the app (not hot reload) for native changes to take effect');
          }
        }
      }
      
      // Check PhonePe
      try {
        final result = await _channel.invokeMethod('checkAppInstalled', {
          'packageName': phonePePackage,
        });
        _appInstalledStatus[phonePePackage] = result == true;
        print('📦 $phonePePackage: ${result == true ? "✅ INSTALLED" : "❌ NOT INSTALLED"}');
      } catch (e) {
        _appInstalledStatus[phonePePackage] = false;
        print('📦 $phonePePackage: ⚠️ Method not available - $e');
        print('💡 Note: Rebuild the app (not hot reload) for native changes to take effect');
      }
    } catch (e) {
      print('❌ Error checking app installation: $e');
    } finally {
      setState(() {
        _isCheckingApps = false;
      });
    }
  }

  // Debug: List all Google apps
  Future<void> _listAllGoogleApps() async {
    setState(() {
      _isLoadingDebugInfo = true;
      _googleAppsList = [];
    });
    
    print('\n🔍 ========== LISTING ALL GOOGLE APPS ==========');
    try {
      final result = await _channel.invokeMethod('listAllGoogleApps');
      if (result != null && result is List) {
        _googleAppsList = result.cast<String>();
        print('✅ Found ${_googleAppsList.length} Google-related apps');
        _googleAppsList.forEach((app) => print('  - $app'));
      }
    } catch (e) {
      print('❌ Error listing Google apps: $e');
      _updateResult('Error listing Google apps: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoadingDebugInfo = false;
      });
    }
  }

  // Debug: List all Pay apps
  Future<void> _listAllPayApps() async {
    setState(() {
      _isLoadingDebugInfo = true;
      _payAppsList = [];
    });
    
    print('\n🔍 ========== LISTING ALL PAY APPS ==========');
    try {
      final result = await _channel.invokeMethod('listAllPayApps');
      if (result != null && result is List) {
        _payAppsList = result.cast<String>();
        print('✅ Found ${_payAppsList.length} Pay-related apps');
        _payAppsList.forEach((app) => print('  - $app'));
      }
    } catch (e) {
      print('❌ Error listing Pay apps: $e');
      _updateResult('Error listing Pay apps: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoadingDebugInfo = false;
      });
    }
  }

  // Debug: Check UPI Intent Handlers
  Future<void> _checkUPIHandlers() async {
    setState(() {
      _isLoadingDebugInfo = true;
      _upiHandlersList = [];
    });
    
    print('\n🔍 ========== CHECKING UPI INTENT HANDLERS ==========');
    try {
      final result = await _channel.invokeMethod('checkUPIHandlers');
      if (result != null && result is List) {
        _upiHandlersList = result.cast<String>();
        print('✅ Found ${_upiHandlersList.length} apps that can handle UPI URLs');
        _upiHandlersList.forEach((handler) => print('  - $handler'));
        
        if (_upiHandlersList.isEmpty) {
          _updateResult('No UPI handlers found - Google Pay may not be installed', isSuccess: false);
        } else {
          _updateResult('Found ${_upiHandlersList.length} UPI handlers', isSuccess: true);
        }
      }
    } catch (e) {
      print('❌ Error checking UPI handlers: $e');
      _updateResult('Error checking UPI handlers: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoadingDebugInfo = false;
      });
    }
  }

  // Debug: Aggressive Google Pay Search
  Future<void> _searchForGooglePay() async {
    setState(() {
      _isLoadingDebugInfo = true;
      _googlePayCandidates = {};
    });
    
    print('\n🔍 ========== AGGRESSIVE GOOGLE PAY SEARCH ==========');
    try {
      final result = await _channel.invokeMethod('searchForGooglePay');
      if (result != null && result is Map) {
        _googlePayCandidates = Map<String, String>.from(result);
        print('✅ Found ${_googlePayCandidates.length} Google Pay candidates');
        _googlePayCandidates.forEach((pkg, name) => print('  - $pkg -> $name'));
        
        if (_googlePayCandidates.isEmpty) {
          _updateResult('Google Pay not found - Try installing from Play Store', isSuccess: false);
        } else {
          final firstFound = _googlePayCandidates.entries.first;
          _updateResult('Found Google Pay: ${firstFound.key} -> ${firstFound.value}', isSuccess: true);
        }
      }
    } catch (e) {
      print('❌ Error searching for Google Pay: $e');
      _updateResult('Error searching for Google Pay: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoadingDebugInfo = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Check app installation on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppInstallation();
    });
  }

  // ========== GOOGLE PAY METHODS ==========
  
  // Method 1: URL Launcher - External Application
  Future<void> _testGooglePayMethod1() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 1: URL Launcher (External) ==========');
    try {
      final uri = Uri.parse(testUpiUrl);
      print('📋 UPI URL: $testUpiUrl');
      print('📋 Parsed URI: $uri');
      
      final canLaunch = await canLaunchUrl(uri);
      print('✅ Can launch URL: $canLaunch');
      
      if (canLaunch) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Launch result: $launched');
        _updateResult('Method 1: URL Launcher (External) - Launched: $launched', isSuccess: launched);
      } else {
        print('❌ Cannot launch URL');
        _updateResult('Method 1: Cannot launch URL', isSuccess: false);
      }
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 1: Error - $e', isSuccess: false);
    }
  }

  // Method 2: URL Launcher - Platform Default
  Future<void> _testGooglePayMethod2() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 2: URL Launcher (Platform Default) ==========');
    try {
      final uri = Uri.parse(testUpiUrl);
      print('📋 UPI URL: $testUpiUrl');
      
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      print('✅ Launch result: $launched');
      _updateResult('Method 2: URL Launcher (Platform Default) - Launched: $launched', isSuccess: launched);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 2: Error - $e', isSuccess: false);
    }
  }

  // Method 3: URL Launcher - In App WebView
  Future<void> _testGooglePayMethod3() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 3: URL Launcher (In App WebView) ==========');
    try {
      final uri = Uri.parse(testUpiUrl);
      print('📋 UPI URL: $testUpiUrl');
      
      final launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      print('✅ Launch result: $launched');
      _updateResult('Method 3: URL Launcher (In App WebView) - Launched: $launched', isSuccess: launched);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 3: Error - $e', isSuccess: false);
    }
  }

  // Method 4: Native Method Channel - openGooglePay
  Future<void> _testGooglePayMethod4() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 4: Native Method Channel (openGooglePay) ==========');
    try {
      print('📋 UPI URL: $testUpiUrl');
      print('📋 Calling native method: openGooglePay');
      
      final result = await _channel.invokeMethod('openGooglePay', {
        'upiUrl': testUpiUrl,
      });
      
      print('✅ Native method result: $result');
      _updateResult('Method 4: Native (openGooglePay) - Result: $result', isSuccess: true);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 4: Error - $e', isSuccess: false);
    }
  }

  // Method 5: Native Method Channel - openUPIApp (first package)
  Future<void> _testGooglePayMethod5() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 5: Native Method Channel (openUPIApp - Package 1) ==========');
    try {
      final packageName = googlePayPackages[0];
      print('📋 UPI URL: $testUpiUrl');
      print('📋 Package Name: $packageName');
      print('📋 Calling native method: openUPIApp');
      
      final result = await _channel.invokeMethod('openUPIApp', {
        'upiUrl': testUpiUrl,
        'packageName': packageName,
      });
      
      print('✅ Native method result: $result');
      _updateResult('Method 5: Native (openUPIApp - $packageName) - Result: $result', isSuccess: result == true);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 5: Error - $e', isSuccess: false);
    }
  }

  // Method 6: Native Method Channel - openUPIApp (second package)
  Future<void> _testGooglePayMethod6() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 6: Native Method Channel (openUPIApp - Package 2) ==========');
    try {
      final packageName = googlePayPackages[1];
      print('📋 UPI URL: $testUpiUrl');
      print('📋 Package Name: $packageName');
      
      final result = await _channel.invokeMethod('openUPIApp', {
        'upiUrl': testUpiUrl,
        'packageName': packageName,
      });
      
      print('✅ Native method result: $result');
      _updateResult('Method 6: Native (openUPIApp - $packageName) - Result: $result', isSuccess: result == true);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 6: Error - $e', isSuccess: false);
    }
  }

  // Method 7: Native Method Channel - openUPIApp (third package)
  Future<void> _testGooglePayMethod7() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 7: Native Method Channel (openUPIApp - Package 3) ==========');
    try {
      final packageName = googlePayPackages[2];
      print('📋 UPI URL: $testUpiUrl');
      print('📋 Package Name: $packageName');
      
      final result = await _channel.invokeMethod('openUPIApp', {
        'upiUrl': testUpiUrl,
        'packageName': packageName,
      });
      
      print('✅ Native method result: $result');
      _updateResult('Method 7: Native (openUPIApp - $packageName) - Result: $result', isSuccess: result == true);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 7: Error - $e', isSuccess: false);
    }
  }

  // Method 8: Native Method Channel - Forced Chooser (ALWAYS shows chooser like URL launcher)
  Future<void> _testGooglePayMethod8() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 8: Native Forced Chooser (BEST METHOD!) ==========');
    try {
      print('📋 UPI URL: $testUpiUrl');
      print('📋 Calling native method: openUPIWithChooser (ALWAYS shows chooser)');
      
      final result = await _channel.invokeMethod('openUPIWithChooser', {
        'upiUrl': testUpiUrl,
      });
      
      print('✅ Native method result: $result');
      _updateResult('Method 8: Native Forced Chooser - Result: $result (This ALWAYS shows chooser!)', isSuccess: result == true);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 8: Error - $e', isSuccess: false);
    }
  }

  // Method 9: Direct GPay URL Scheme
  Future<void> _testGooglePayMethod9() async {
    print('\n🔵 ========== GOOGLE PAY METHOD 8: Direct GPay URL Scheme ==========');
    try {
      // Try different GPay URL schemes
      final gpayUrls = [
        'gpay://pay?pa=test@upi&pn=TestMerchant&am=100&cu=INR',
        'tez://pay?pa=test@upi&pn=TestMerchant&am=100&cu=INR',
        'googlepay://pay?pa=test@upi&pn=TestMerchant&am=100&cu=INR',
      ];
      
      for (int i = 0; i < gpayUrls.length; i++) {
        try {
          print('📋 Trying GPay URL ${i + 1}: ${gpayUrls[i]}');
          final uri = Uri.parse(gpayUrls[i]);
          
          if (await canLaunchUrl(uri)) {
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('✅ Launched GPay URL ${i + 1}: $launched');
            _updateResult('Method 8: GPay URL Scheme ${i + 1} - Launched: $launched', isSuccess: launched);
            return;
          }
        } catch (e) {
          print('⚠️ GPay URL ${i + 1} failed: $e');
        }
      }
      
      _updateResult('Method 8: All GPay URL schemes failed', isSuccess: false);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('Method 8: Error - $e', isSuccess: false);
    }
  }

  // ========== PHONEPE METHODS ==========
  
  // Method 1: URL Launcher - External Application
  Future<void> _testPhonePeMethod1() async {
    print('\n🟣 ========== PHONEPE METHOD 1: URL Launcher (External) ==========');
    try {
      final uri = Uri.parse(testUpiUrl);
      print('📋 UPI URL: $testUpiUrl');
      
      final canLaunch = await canLaunchUrl(uri);
      print('✅ Can launch URL: $canLaunch');
      
      if (canLaunch) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Launch result: $launched');
        _updateResult('PhonePe Method 1: URL Launcher (External) - Launched: $launched', isSuccess: launched);
      } else {
        print('❌ Cannot launch URL');
        _updateResult('PhonePe Method 1: Cannot launch URL', isSuccess: false);
      }
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('PhonePe Method 1: Error - $e', isSuccess: false);
    }
  }

  // Method 2: Native Method Channel - openUPIApp
  Future<void> _testPhonePeMethod2() async {
    print('\n🟣 ========== PHONEPE METHOD 2: Native Method Channel (openUPIApp) ==========');
    try {
      print('📋 UPI URL: $testUpiUrl');
      print('📋 Package Name: $phonePePackage');
      
      final result = await _channel.invokeMethod('openUPIApp', {
        'upiUrl': testUpiUrl,
        'packageName': phonePePackage,
      });
      
      print('✅ Native method result: $result');
      _updateResult('PhonePe Method 2: Native (openUPIApp) - Result: $result', isSuccess: result == true);
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('PhonePe Method 2: Error - $e', isSuccess: false);
    }
  }

  // Method 3: Direct PhonePe URL Scheme
  Future<void> _testPhonePeMethod3() async {
    print('\n🟣 ========== PHONEPE METHOD 3: Direct PhonePe URL Scheme ==========');
    try {
      final phonepeUrl = 'phonepe://pay?pa=test@upi&pn=TestMerchant&am=100&cu=INR';
      print('📋 PhonePe URL: $phonepeUrl');
      
      final uri = Uri.parse(phonepeUrl);
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Launch result: $launched');
        _updateResult('PhonePe Method 3: Direct URL Scheme - Launched: $launched', isSuccess: launched);
      } else {
        print('❌ Cannot launch PhonePe URL');
        _updateResult('PhonePe Method 3: Cannot launch URL', isSuccess: false);
      }
    } catch (e) {
      print('❌ Error: $e');
      _updateResult('PhonePe Method 3: Error - $e', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Test Page'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Installation Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'App Installation Status:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (_isCheckingApps)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _checkAppInstallation,
                          tooltip: 'Refresh status',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Google Pay status
                  if (_foundGooglePayPackage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Found Google Pay: $_foundGooglePayPackage',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...googlePayPackages.map((package) {
                    final isInstalled = _appInstalledStatus[package] ?? false;
                    final isFoundPackage = _foundGooglePayPackage == package;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            isInstalled ? Icons.check_circle : Icons.cancel,
                            color: isInstalled ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Google Pay ($package): ${isInstalled ? "INSTALLED ✅" : "NOT INSTALLED ❌"}${isFoundPackage ? " (ACTUAL PACKAGE)" : ""}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isInstalled ? Colors.green.shade700 : Colors.red.shade700,
                                fontWeight: isFoundPackage ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // PhonePe status
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          _appInstalledStatus[phonePePackage] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _appInstalledStatus[phonePePackage] == true
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PhonePe: ${_appInstalledStatus[phonePePackage] == true ? "INSTALLED ✅" : "NOT INSTALLED ❌"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _appInstalledStatus[phonePePackage] == true
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Result Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lastResultColor.withOpacity(0.1),
                border: Border.all(color: _lastResultColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Result:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastResult,
                    style: TextStyle(color: _lastResultColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Google Pay Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'GOOGLE PAY TEST BUTTONS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      if (googlePayPackages.any((pkg) => _appInstalledStatus[pkg] == true))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'INSTALLED',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NOT INSTALLED',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Method 1: URL Launcher (External)',
                    Colors.blue,
                    _testGooglePayMethod1,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 2: URL Launcher (Platform Default)',
                    Colors.blue.shade700,
                    _testGooglePayMethod2,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 3: URL Launcher (In App WebView)',
                    Colors.blue.shade800,
                    _testGooglePayMethod3,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 4: Native (openGooglePay)',
                    Colors.blue.shade900,
                    _testGooglePayMethod4,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 5: Native (openUPIApp - Package 1)',
                    Colors.indigo,
                    _testGooglePayMethod5,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 6: Native (openUPIApp - Package 2)',
                    Colors.indigo.shade700,
                    _testGooglePayMethod6,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 7: Native (openUPIApp - Package 3)',
                    Colors.indigo.shade900,
                    _testGooglePayMethod7,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 8: Native Forced Chooser ⭐ (BEST!)',
                    Colors.green,
                    _testGooglePayMethod8,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 9: Direct GPay URL Scheme',
                    Colors.cyan,
                    _testGooglePayMethod9,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // PhonePe Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'PHONEPE TEST BUTTONS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      if (_appInstalledStatus[phonePePackage] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'INSTALLED',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NOT INSTALLED',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Method 1: URL Launcher (External)',
                    Colors.purple,
                    _testPhonePeMethod1,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 2: Native (openUPIApp)',
                    Colors.purple.shade700,
                    _testPhonePeMethod2,
                  ),
                  const SizedBox(height: 8),
                  _buildButton(
                    'Method 3: Direct PhonePe URL Scheme',
                    Colors.purple.shade900,
                    _testPhonePeMethod3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Summary Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 TEST RESULTS SUMMARY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '✅ WORKING METHODS:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text('• PhonePe Method 2: Native (openUPIApp)', style: TextStyle(fontSize: 12)),
                  const Text('• PhonePe Method 3: Direct PhonePe URL Scheme (phonepe://)', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  const Text(
                    '❌ NOT WORKING:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text('• All Google Pay methods (Google Pay not installed)', style: TextStyle(fontSize: 12)),
                  const Text('• PhonePe Method 1: URL Launcher (upi:// URLs not supported)', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  const Text(
                    '💡 RECOMMENDATION:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use Native Method Channel (openUPIApp) or Direct URL Schemes (phonepe://, gpay://) for best results. URL Launcher with upi:// scheme does not work reliably.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Debug Section - Find Google Pay
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 DEBUG: Find Google Pay Package',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If Google Pay is installed but not detected, use these buttons to find the actual package name:',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingDebugInfo ? null : _listAllGoogleApps,
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('List All Google Apps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingDebugInfo ? null : _listAllPayApps,
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('List All Pay Apps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingDebugInfo ? null : _checkUPIHandlers,
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Check UPI Intent Handlers (Most Important!)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingDebugInfo ? null : _searchForGooglePay,
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('🔍 Aggressive Google Pay Search (NEW!)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_isLoadingDebugInfo)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_googleAppsList.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Google Apps Found:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _googleAppsList.map((app) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: SelectableText(
                                app,
                                style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  if (_payAppsList.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Pay Apps Found:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _payAppsList.map((app) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: SelectableText(
                                app,
                                style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  if (_googlePayCandidates.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.red, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'Google Pay Candidates Found:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'These apps might be Google Pay:',
                            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _googlePayCandidates.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.green, size: 12),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: SelectableText(
                                            '${entry.key} -> ${entry.value}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_upiHandlersList.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'UPI Intent Handlers Found:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'These apps can actually handle UPI URLs:',
                            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _upiHandlersList.map((handler) {
                                  final isPotentialGooglePay = handler.toLowerCase().contains('google') && 
                                                               (handler.toLowerCase().contains('pay') || 
                                                                handler.toLowerCase().contains('paisa') ||
                                                                handler.toLowerCase().contains('wallet'));
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        if (isPotentialGooglePay)
                                          const Icon(Icons.star, color: Colors.orange, size: 12),
                                        if (isPotentialGooglePay) const SizedBox(width: 4),
                                        Expanded(
                                          child: SelectableText(
                                            handler,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'monospace',
                                              fontWeight: isPotentialGooglePay ? FontWeight.bold : FontWeight.normal,
                                              color: isPotentialGooglePay ? Colors.orange.shade900 : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test UPI URL:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    testUpiUrl,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  if (_foundGooglePayPackage == null && googlePayPackages.every((pkg) => _appInstalledStatus[pkg] != true))
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ IMPORTANT:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'If you installed Google Pay but it\'s not detected:',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '1. Use the DEBUG section above to find the actual package name',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '2. Check the console logs for detailed information',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '3. Rebuild the app if you made native code changes',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: Check console/debug output for detailed logs',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

