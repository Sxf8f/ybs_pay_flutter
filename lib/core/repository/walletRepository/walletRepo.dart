import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/walletModels/walletModel.dart';
import '../../auth/httpClient.dart';

class WalletRepository {
  /// Get wallet balance
  Future<WalletBalanceResponse> getWalletBalance() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/wallet/balance/');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Wallet API - Response status: ${response.statusCode}');
    print('Wallet API - Response headers: ${response.headers}');
    print('Wallet API - Response body: ${response.body}');

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return WalletBalanceResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch wallet balance';
      throw Exception(errorMsg);
    }
  }

  /// Get payment methods
  Future<PaymentMethodsResponse> getPaymentMethods() async {
    print('=== PAYMENT METHODS API REQUEST ===');
    final url = Uri.parse('${AssetsConst.apiBase}api/android/wallet/payment-methods/');
    print('URL: $url');
    print('Timestamp: ${DateTime.now()}');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('=== PAYMENT METHODS API RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body Length: ${response.body.length} bytes');
    print('Response Body (raw): ${response.body}');

    final data = json.decode(response.body);
    print('JSON parsed successfully');
    print('=== PARSED RESPONSE DATA ===');
    print('Response type: ${data.runtimeType}');
    print('Success: ${data['success']}');
    print('PG Active: ${data['pg_active']}');
    print('Total Count: ${data['total_count']}');
    print('Message: ${data['message']}');
    print('Current Balance: ${data['current_balance']}');
    print('Current Balance Display: ${data['current_balance_display']}');
    
    if (data['payment_methods'] != null) {
      print('Payment Methods Array Length: ${(data['payment_methods'] as List).length}');
      print('=== PAYMENT METHODS DETAILS ===');
      for (int i = 0; i < (data['payment_methods'] as List).length; i++) {
        final method = data['payment_methods'][i];
        print('Method ${i + 1}:');
        print('  - Operator: ${method['operator']}');
        print('  - Operator Display: ${method['operator_display']}');
        print('  - Gateway ID: ${method['gateway_id']}');
        print('  - Gateway Name: ${method['gateway_name']}');
        print('  - Is Active: ${method['is_active']}');
        if (method['charge_info'] != null) {
          print('  - Charge Info:');
          print('    * Charge: ${method['charge_info']['charge']}');
          print('    * Is Fixed: ${method['charge_info']['is_fixed']}');
          print('    * Charge Display: ${method['charge_info']['charge_display']}');
          print('    * Charge Type: ${method['charge_info']['charge_type']}');
          print('    * Min Amount: ${method['charge_info']['min_amount']}');
          print('    * Max Amount: ${method['charge_info']['max_amount']}');
          print('    * Min Amount Display: ${method['charge_info']['min_amount_display']}');
          print('    * Max Amount Display: ${method['charge_info']['max_amount_display']}');
        } else {
          print('  - Charge Info: null');
        }
      }
    } else {
      print('Payment Methods: null or not an array');
    }
    print('Full response data: $data');

    if (response.statusCode == 200) {
      print('Creating PaymentMethodsResponse object...');
      try {
        final paymentMethodsResponse = PaymentMethodsResponse.fromJson(data);
        print('=== PaymentMethodsResponse CREATED SUCCESSFULLY ===');
        print('Success: ${paymentMethodsResponse.success}');
        print('PG Active: ${paymentMethodsResponse.pgActive}');
        print('Total Count: ${paymentMethodsResponse.totalCount}');
        print('Payment Methods Count: ${paymentMethodsResponse.paymentMethods.length}');
        print('Message: ${paymentMethodsResponse.message}');
        print('Current Balance: ${paymentMethodsResponse.currentBalance}');
        print('Current Balance Display: ${paymentMethodsResponse.currentBalanceDisplay}');
        return paymentMethodsResponse;
      } catch (e, stackTrace) {
        print('=== ERROR CREATING PaymentMethodsResponse ===');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        print('Stack trace: $stackTrace');
        print('Data that failed to parse: $data');
        rethrow;
      }
    } else {
      print('=== API RESPONSE INDICATES FAILURE ===');
      print('Status Code: ${response.statusCode}');
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch payment methods';
      print('Error Message: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Add money to wallet
  Future<AddMoneyResponse> addMoney(String amount, String operator, {String? secureKey}) async {
    print('=== WalletRepository.addMoney() CALLED ===');
    print('Timestamp: ${DateTime.now()}');
    print('Amount: $amount');
    print('Operator: $operator');
    final hasSecureKey = secureKey != null && secureKey.isNotEmpty;
    print('Has Secure Key: $hasSecureKey');
    
    final bodyMap = <String, dynamic>{
      'amount': amount,
      'operator': operator,
    };
    
    if (secureKey != null && secureKey.isNotEmpty) {
      bodyMap['secure_key'] = secureKey;
      print('Secure key added to request body (length: ${secureKey.length})');
    } else {
      print('No secure key provided');
    }

    final url = Uri.parse('${AssetsConst.apiBase}api/android/wallet/add-money/');

    print('=== ADD MONEY API REQUEST ===');
    print('URL: $url');
    print('Base URL: ${AssetsConst.apiBase}');
    print('Full URL: $url');
    print('Amount: $amount');
    print('Operator: $operator');
    print('Request Body: ${jsonEncode(bodyMap)}');
    print('Request Body length: ${jsonEncode(bodyMap).length} bytes');

    try {
      print('Calling AuthenticatedHttpClient.post()...');
      print('Before API call timestamp: ${DateTime.now()}');
      
      final response = await AuthenticatedHttpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: bodyMap,
      );
      
      print('=== API CALL COMPLETED ===');
      print('After API call timestamp: ${DateTime.now()}');
      print('Response received successfully');

      print('=== ADD MONEY API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body Length: ${response.body.length} bytes');
      print('Response Body (raw): ${response.body}');

      if (response.statusCode != 200) {
        print('WARNING: Non-200 status code received: ${response.statusCode}');
      }

      print('Parsing JSON response...');
      final data = json.decode(response.body);
      print('JSON parsed successfully');
    
    // Print complete API response in formatted JSON for QR webview debugging
    print('\n' + '='*80);
    print('📱 COMPLETE API RESPONSE FOR QR WEBVIEW');
    print('='*80);
    try {
      final formattedJson = const JsonEncoder.withIndent('  ').convert(data);
      print(formattedJson);
    } catch (e) {
      print('Could not format JSON, printing raw: $data');
    }
    print('='*80 + '\n');
    
    print('=== RESPONSE DATA TYPES ===');
    print('Response type: ${data.runtimeType}');
    print('Success type: ${data['success'].runtimeType}, value: ${data['success']}');
    print('Message type: ${data['message'].runtimeType}, value: ${data['message']}');
    print('Transaction ID type: ${data['transaction_id'].runtimeType}, value: ${data['transaction_id']}');
    print('Live ID type: ${data['live_id']?.runtimeType}, value: ${data['live_id']}');
    print('Amount type: ${data['amount'].runtimeType}, value: ${data['amount']}');
    print('Payment URL type: ${data['payment_url']?.runtimeType}, value: ${data['payment_url']}');
    print('UPI URL type: ${data['upi_url']?.runtimeType}, value: ${data['upi_url']}');
    print('UPI URL exists: ${data.containsKey('upi_url')}');
    print('UPI URL is null: ${data['upi_url'] == null}');
    print('UPI URL isEmpty: ${data['upi_url'] is String && (data['upi_url'] as String).isEmpty}');
    
    // Check for upi_intent field (NEW from backend update)
    print('\n=== CHECKING upi_intent FIELD (NEW) ===');
    print('upi_intent exists: ${data.containsKey('upi_intent')}');
    print('upi_intent type: ${data['upi_intent']?.runtimeType}');
    print('upi_intent is null: ${data['upi_intent'] == null}');
    if (data['upi_intent'] != null && data['upi_intent'] is Map<String, dynamic>) {
      final upiIntent = data['upi_intent'] as Map<String, dynamic>;
      print('✅ upi_intent object found!');
      print('  - bhim_link: ${upiIntent['bhim_link'] ?? "null"}');
      print('  - phonepe_link: ${upiIntent['phonepe_link'] ?? "null"}');
      print('  - paytm_link: ${upiIntent['paytm_link'] ?? "null"}');
      print('  - gpay_link: ${upiIntent['gpay_link'] ?? "null"}');
    } else {
      print('⚠️ upi_intent not found or invalid (will use generic upi_url)');
    }
    
    print('Status type: ${data['status']?.runtimeType}, value: ${data['status']}');
    print('Redirect type: ${data['redirect'].runtimeType}, value: ${data['redirect']}');
    print('Gateway Name type: ${data['gateway_name']?.runtimeType}, value: ${data['gateway_name']}');
    print('Operator type: ${data['operator']?.runtimeType}, value: ${data['operator']}');
    print('Old Balance type: ${data['old_balance']?.runtimeType}, value: ${data['old_balance']}');
    print('New Balance type: ${data['new_balance']?.runtimeType}, value: ${data['new_balance']}');
    
    // Print all keys in the response to see what fields are included
    print('\n=== ALL RESPONSE KEYS ===');
    print('Keys in response: ${data.keys.toList()}');
    print('Total number of keys: ${data.keys.length}');
    
    // Print each key-value pair
    print('\n=== KEY-VALUE PAIRS ===');
    data.forEach((key, value) {
      print('$key: ${value.runtimeType} = $value');
    });

      print('Checking response status and success flag...');
      print('Status Code: ${response.statusCode}');
      print('Success flag: ${data['success']}');
      print('Success flag type: ${data['success'].runtimeType}');
      
      if (response.statusCode == 200 && data['success'] == true) {
        print('Response is successful, creating AddMoneyResponse object...');
        try {
          final addMoneyResponse = AddMoneyResponse.fromJson(data);
          print('=== AddMoneyResponse CREATED SUCCESSFULLY ===');
          print('Transaction ID: ${addMoneyResponse.transactionId}');
          print('Amount: ${addMoneyResponse.amount}');
          print('Payment URL: ${addMoneyResponse.paymentUrl ?? "null"}');
          print('UPI URL: ${addMoneyResponse.upiUrl ?? "null"}');
          print('UPI URL is null: ${addMoneyResponse.upiUrl == null}');
          print('UPI URL isEmpty: ${addMoneyResponse.upiUrl?.isEmpty ?? true}');
          print('UPI URL length: ${addMoneyResponse.upiUrl?.length ?? 0}');
          
          // Log UPI Intent Links (NEW from backend update)
          print('\n=== UPI INTENT LINKS STATUS ===');
          if (addMoneyResponse.upiIntentLinks != null) {
            print('✅ UPI Intent Links available!');
            print('  - BHIM Link: ${addMoneyResponse.upiIntentLinks!.bhimLink ?? "null"}');
            print('  - PhonePe Link: ${addMoneyResponse.upiIntentLinks!.phonepeLink ?? "null"}');
            print('  - Paytm Link: ${addMoneyResponse.upiIntentLinks!.paytmLink ?? "null"}');
            print('  - GPay Link: ${addMoneyResponse.upiIntentLinks!.gpayLink ?? "null"}');
            print('✅ App will use specific UPI app links for better reliability!');
          } else {
            print('⚠️ UPI Intent Links not available');
            print('⚠️ App will fall back to generic upi_url');
          }
          
          print('Redirect: ${addMoneyResponse.redirect}');
          print('Charge: ${addMoneyResponse.charge}');
          print('Net Amount: ${addMoneyResponse.netAmount}');
          print('Charge Type: ${addMoneyResponse.chargeType}');
          print('Returning AddMoneyResponse...');
          return addMoneyResponse;
        } catch (e, stackTrace) {
          print('=== ERROR CREATING AddMoneyResponse ===');
          print('Error: $e');
          print('Error type: ${e.runtimeType}');
          print('Stack trace: $stackTrace');
          print('Data that failed to parse: $data');
          rethrow;
        }
      } else {
        print('=== API RESPONSE INDICATES FAILURE ===');
        print('Status Code: ${response.statusCode}');
        print('Success: ${data['success']}');
        print('Error Code: ${data['error_code']}');
        print('Message: ${data['message']}');
        print('Error: ${data['error']}');
        print('Detail: ${data['detail']}');
        print('Requires Secure Key: ${data['requires_secure_key']}');
        
        // Check if backend is requiring secure key (even though we removed it from UI)
        if (data['requires_secure_key'] == true) {
          final errorMsg = 'Backend API requires secure key. Please configure the backend to allow add money without secure key validation.';
          print('Backend requires secure key - this should be disabled in backend configuration');
          throw Exception(errorMsg);
        }
        
        final errorMsg = data['error'] ?? 
                        data['detail'] ?? 
                        data['message'] ?? 
                        'Failed to add money';
        print('Throwing exception with message: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      print('=== EXCEPTION IN WalletRepository.addMoney() ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      
      // Check if it's a network/timeout error
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        print('Network error detected');
      }
      
      rethrow;
    }
  }

  /// Check payment status
  /// NOTE: Currently using POST as backend only supports POST, OPTIONS
  /// TODO: Update to GET when backend supports GET method
  Future<PaymentStatusResponse> checkPaymentStatus(String transactionId) async {
    print('=== WalletRepository.checkPaymentStatus() CALLED ===');
    print('Timestamp: ${DateTime.now()}');
    print('Transaction ID: $transactionId');
    
    final url = Uri.parse('${AssetsConst.apiBase}api/android/wallet/check-status/');
    print('URL: $url');
    
    final body = {
      'transaction_id': transactionId,
    };
    print('Request Body: ${jsonEncode(body)}');
    
    try {
      print('Calling AuthenticatedHttpClient.post()...');
      print('Before API call timestamp: ${DateTime.now()}');
      
      final response = await AuthenticatedHttpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      
      print('=== CHECK STATUS API RESPONSE ===');
      print('After API call timestamp: ${DateTime.now()}');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body Length: ${response.body.length} bytes');
      print('Response Body: ${response.body}');

      final data = json.decode(response.body);
      print('JSON parsed successfully');

      if (response.statusCode == 200 && data['success'] == true) {
        print('Response is successful, creating PaymentStatusResponse...');
        try {
          final statusResponse = PaymentStatusResponse.fromJson(data);
          print('PaymentStatusResponse created successfully');
          print('Status: ${statusResponse.status}');
          print('Transaction ID: ${statusResponse.transactionId}');
          return statusResponse;
        } catch (e, stackTrace) {
          print('ERROR creating PaymentStatusResponse: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        print('=== CHECK STATUS API RESPONSE INDICATES FAILURE ===');
        print('Status Code: ${response.statusCode}');
        print('Success: ${data['success']}');
        print('Error Code: ${data['error_code']}');
        print('Message: ${data['message']}');
        print('Error: ${data['error']}');
        print('Detail: ${data['detail']}');
        
        final errorMsg = data['error'] ?? 
                        data['detail'] ?? 
                        data['message'] ?? 
                        'Failed to check payment status';
        print('Throwing exception with message: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      print('=== EXCEPTION IN WalletRepository.checkPaymentStatus() ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      print('URL that failed: $url');
      rethrow;
    }
  }

  /// Get wallet history
  Future<WalletHistoryResponse> getWalletHistory({
    String? status,
    String? startDate,
    String? endDate,
    int? limit,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('${AssetsConst.apiBase}api/android/wallet/history/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return WalletHistoryResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch wallet history';
      throw Exception(errorMsg);
    }
  }

  /// Generate QR code for user
  Future<QRCodeResponse> generateQR() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/wallet/generate-qr/');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return QRCodeResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to generate QR code';
      throw Exception(errorMsg);
    }
  }

  /// Validate QR code and get recipient info
  Future<ValidateQRResponse> validateQR(String qrData) async {
    final body = {
      'qr_data': qrData,
    };

    final url = Uri.parse('${AssetsConst.apiBase}api/android/wallet/validate-qr/');
    
    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ValidateQRResponse.fromJson(data);
    } else {
      // Return error response even for 400/404
      return ValidateQRResponse.fromJson(data);
    }
  }

  /// Transfer money to another user
  Future<TransferMoneyResponse> transferMoney({
    required int recipientUserId,
    required String amount,
    String? remarks,
    String? qrData,
    String? secureKey,
  }) async {
    final bodyMap = <String, dynamic>{
      'recipient_user_id': recipientUserId,
      'amount': amount,
    };
    if (remarks != null && remarks.isNotEmpty) {
      bodyMap['remarks'] = remarks;
    }
    if (qrData != null && qrData.isNotEmpty) {
      bodyMap['qr_data'] = qrData;
    }
    if (secureKey != null && secureKey.isNotEmpty) {
      bodyMap['secure_key'] = secureKey;
    }

    final url = Uri.parse('${AssetsConst.apiBase}api/android/wallet/transfer-money/');
    
    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: bodyMap,
    );
    final data = json.decode(response.body);

    print('Transfer Money API Response Status: ${response.statusCode}');
    print('Transfer Money API Response Body: $data');

    if (response.statusCode == 200 && data['success'] == true) {
      return TransferMoneyResponse.fromJson(data);
    } else if (response.statusCode == 403) {
      // Handle permission denied (role-based transfer restrictions)
      final errorMsg = data['error'] ?? 
                      data['message'] ?? 
                      'Transfer not allowed. Your account role does not have permission to transfer funds to this recipient.';
      throw Exception(errorMsg);
    } else if (response.statusCode == 500) {
      // Handle server errors
      final errorMsg = data['error'] ?? 
                      data['message'] ?? 
                      'Server error occurred. Please try again later or contact support.';
      print('Server Error Details: ${data.toString()}');
      throw Exception(errorMsg);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to transfer money';
      throw Exception(errorMsg);
    }
  }

  /// Get transfer history (P2P transfers)
  Future<TransferHistoryResponse> getTransferHistory({
    String? type,
    String? startDate,
    String? endDate,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final uri = Uri.parse('${AssetsConst.apiBase}api/android/wallet/transfer-history/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return TransferHistoryResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch transfer history';
      throw Exception(errorMsg);
    }
  }
}

