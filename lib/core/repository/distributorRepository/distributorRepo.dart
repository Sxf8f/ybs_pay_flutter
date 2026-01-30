import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/distributorModels/distributorDashboardModel.dart';
import '../../models/distributorModels/distributorUserModel.dart';
import '../../models/distributorModels/distributorReportModel.dart';
import '../../models/distributorModels/distributorCommissionModel.dart';
import '../../models/distributorModels/distributorScanPayModel.dart';
import '../../models/distributorModels/distributorFundTransferModel.dart';
import '../../auth/httpClient.dart';

class DistributorRepository {
  /// Fetch Distributor Dashboard
  Future<DistributorDashboardResponse> fetchDashboard() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/dashboard/');
    
    print('📡 [Dashboard API] Fetching dashboard from: $url');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('📡 [Dashboard API] Response status: ${response.statusCode}');
    print('📡 [Dashboard API] Response body: ${response.body}');

    final data = json.decode(response.body);
    
    print('📡 [Dashboard API] Parsed JSON type: ${data.runtimeType}');
    print('📡 [Dashboard API] Parsed JSON keys: ${data is Map ? data.keys.toList() : "Not a Map"}');

    if (response.statusCode == 200) {
      try {
        final dashboardResponse = DistributorDashboardResponse.fromJson(data);
        print('✅ [Dashboard API] Successfully parsed dashboard response');
        return dashboardResponse;
      } catch (e, stackTrace) {
        print('❌ [Dashboard API] Error parsing dashboard response: $e');
        print('❌ [Dashboard API] Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch dashboard';
      print('❌ [Dashboard API] API Error: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Get User List
  Future<UserListResponse> getUserList({
    int? page,
    int? limit,
    String? search,
    String? role,
    String? criteria,
    String? searchValue,
    String? phoneNumber,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (search != null) queryParams['search'] = search;
    if (role != null) queryParams['role'] = role;
    // Support old parameters for backward compatibility
    if (criteria != null) queryParams['criteria'] = criteria;
    if (searchValue != null) queryParams['search_value'] = searchValue;
    if (phoneNumber != null) queryParams['phone_number'] = phoneNumber;

    final uri = Uri.parse('${AssetsConst.apiBase}api/distributor/users/list/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserListResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch user list';
      throw Exception(errorMsg);
    }
  }

  /// Get User List (POST method)
  Future<UserListResponse> getUserListPost({
    int? page,
    int? limit,
    String? search,
    String? role,
    String? criteria,
    String? searchValue,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (page != null) body['page'] = page;
    if (limit != null) body['limit'] = limit;
    if (search != null) body['search'] = search;
    if (role != null) body['role'] = role;
    // Support old parameters for backward compatibility
    if (criteria != null) body['criteria'] = criteria;
    if (searchValue != null) body['search_value'] = searchValue;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/users/list/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserListResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch user list';
      throw Exception(errorMsg);
    }
  }

  /// Create User
  /// Note: slab_id is NOT sent - API auto-assigns signupb2b enabled slab
  Future<CreateUserResponse> createUser({
    required String username,
    required String email,
    required String phoneNumber,
    String? pincode,
    String? address,
    String? outlet,
    int? roleId, // Optional: 6 for Retailer (default), 3 for API User
  }) async {
    final body = {
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      if (address != null && address.isNotEmpty) 'address': address,
      if (outlet != null && outlet.isNotEmpty) 'outlet': outlet,
      if (roleId != null) 'role_id': roleId,
      // slab_id is NOT sent - API auto-assigns signupb2b enabled slab
    };

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/users/create/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreateUserResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to create user';
      throw Exception(errorMsg);
    }
  }

  /// Get Commission/Slab
  Future<CommissionSlabResponse> getCommissionSlab() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/commission/slab/');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return CommissionSlabResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch commission slab';
      throw Exception(errorMsg);
    }
  }

  /// Get User Ledger
  Future<UserLedgerResponse> getUserLedger({
    String? startDate,
    String? endDate,
    String? transactionId,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (transactionId != null) queryParams['transaction_id'] = transactionId;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/user-ledger/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserLedgerResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch user ledger';
      throw Exception(errorMsg);
    }
  }

  /// Get User Ledger (POST method)
  Future<UserLedgerResponse> getUserLedgerPost({
    String? startDate,
    String? endDate,
    String? transactionId,
    int? limit,
  }) async {
    final body = <String, dynamic>{};
    if (startDate != null) body['start_date'] = startDate;
    if (endDate != null) body['end_date'] = endDate;
    if (transactionId != null) body['transaction_id'] = transactionId;
    if (limit != null) body['limit'] = limit;

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/user-ledger/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserLedgerResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch user ledger';
      throw Exception(errorMsg);
    }
  }

  /// Get User Daybook
  Future<UserDaybookResponse> getUserDaybook({
    String? phoneNumber,
    String? startDate,
    String? endDate,
    String? operator,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (phoneNumber != null) queryParams['phone_number'] = phoneNumber;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (operator != null) queryParams['operator'] = operator;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/user-daybook/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserDaybookResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch user daybook';
      throw Exception(errorMsg);
    }
  }

  /// Get User Daybook (POST method)
  Future<UserDaybookResponse> getUserDaybookPost({
    String? phoneNumber,
    String? startDate,
    String? endDate,
    String? operator,
    int? limit,
  }) async {
    final body = <String, dynamic>{};
    if (phoneNumber != null) body['phone_number'] = phoneNumber;
    if (startDate != null) body['start_date'] = startDate;
    if (endDate != null) body['end_date'] = endDate;
    if (operator != null) body['operator'] = operator;
    if (limit != null) body['limit'] = limit;

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/user-daybook/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserDaybookResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch user daybook';
      throw Exception(errorMsg);
    }
  }

  /// Get Fund Debit-Credit Report
  Future<FundDebitCreditResponse> getFundDebitCredit({
    int? walletType,
    String? type,
    String? mobile,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (walletType != null) queryParams['wallet_type'] = walletType.toString();
    if (type != null) queryParams['type'] = type;
    if (mobile != null) queryParams['mobile'] = mobile;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/fund-debit-credit/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return FundDebitCreditResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch fund debit-credit report';
      throw Exception(errorMsg);
    }
  }

  /// Get Fund Debit-Credit Report (POST method)
  Future<FundDebitCreditResponse> getFundDebitCreditPost({
    int? walletType,
    String? type,
    String? mobile,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    final body = <String, dynamic>{};
    if (walletType != null) body['wallet_type'] = walletType;
    if (type != null) body['type'] = type;
    if (mobile != null) body['mobile'] = mobile;
    if (startDate != null) body['start_date'] = startDate;
    if (endDate != null) body['end_date'] = endDate;
    if (limit != null) body['limit'] = limit;

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/fund-debit-credit/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return FundDebitCreditResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch fund debit-credit report';
      throw Exception(errorMsg);
    }
  }

  /// Get Dispute Settlement Report
  Future<DisputeSettlementResponse> getDisputeSettlement({
    String? status,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/dispute-settlement/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return DisputeSettlementResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch dispute settlement report';
      throw Exception(errorMsg);
    }
  }

  /// Get Dispute Settlement Report (POST method)
  Future<DisputeSettlementResponse> getDisputeSettlementPost({
    String? status,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (startDate != null) body['start_date'] = startDate;
    if (endDate != null) body['end_date'] = endDate;
    if (limit != null) body['limit'] = limit;

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/reports/dispute-settlement/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return DisputeSettlementResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch dispute settlement report';
      throw Exception(errorMsg);
    }
  }

  // ========== Scan & Pay APIs (Distributor Only) ==========

  /// Generate QR Code for Distributor
  Future<GenerateQRResponse> generateQR() async {
    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/qr/generate/');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return GenerateQRResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to generate QR code';
      throw Exception(errorMsg);
    }
  }

  /// Validate QR Code
  Future<ValidateQRResponse> validateQR(String qrData) async {
    final body = {
      'qr_data': qrData,
    };

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/qr/validate/');

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

  /// Transfer Money via QR Code
  Future<QRTransferResponse> transferViaQR({
    required int recipientUserId,
    required String amount,
    required String qrData,
    String? remarks,
    String? secureKey,
  }) async {
    final body = {
      'recipient_user_id': recipientUserId,
      'amount': amount,
      'qr_data': qrData,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      if (secureKey != null && secureKey.isNotEmpty) 'secure_key': secureKey,
    };

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/qr/transfer/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return QRTransferResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to transfer money';
      throw Exception(errorMsg);
    }
  }

  // ========== Fund Transfer APIs (Distributor Only) ==========

  /// Search Users for Fund Transfer
  Future<FundTransferSearchUsersResponse> searchUsersForTransfer({
    String? search,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('${AssetsConst.apiBase}api/distributor/fund-transfer/search-users/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return FundTransferSearchUsersResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to search users';
      throw Exception(errorMsg);
    }
  }

  /// Search Users for Fund Transfer (POST method)
  Future<FundTransferSearchUsersResponse> searchUsersForTransferPost({
    String? search,
    int? limit,
  }) async {
    final body = <String, dynamic>{};
    if (search != null) body['search'] = search;
    if (limit != null) body['limit'] = limit;

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/fund-transfer/search-users/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return FundTransferSearchUsersResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to search users';
      throw Exception(errorMsg);
    }
  }

  /// Fund Transfer
  Future<FundTransferResponse> fundTransfer({
    required String receiverId,
    required String amount,
    String? remark,
    String? secureKey,
  }) async {
    final body = {
      'receiver_id': receiverId,
      'amount': amount,
      if (remark != null && remark.isNotEmpty) 'remark': remark,
      if (secureKey != null && secureKey.isNotEmpty) 'secure_key': secureKey,
    };

    print('📡 [Fund Transfer API] Request body: $body');

    final url = Uri.parse('${AssetsConst.apiBase}api/distributor/fund-transfer/transfer/');

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('📡 [Fund Transfer API] Response status: ${response.statusCode}');
    print('📡 [Fund Transfer API] Response body: ${response.body}');

    final data = json.decode(response.body);

    // Always parse as FundTransferResponse to handle both success and error cases
    final transferResponse = FundTransferResponse.fromJson(data);

    if (response.statusCode == 200 && transferResponse.success) {
      print('✅ [Fund Transfer API] Transfer successful');
      return transferResponse;
    } else {
      // Handle error responses - check for specific error types
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      transferResponse.error ??
                      'Failed to transfer funds';
      
      print('❌ [Fund Transfer API] Error: $errorMsg');
      print('❌ [Fund Transfer API] Requires secure key: ${transferResponse.requiresSecureKey}');
      print('❌ [Fund Transfer API] Current balance: ${transferResponse.currentBalance}');
      print('❌ [Fund Transfer API] Required amount: ${transferResponse.requiredAmount}');
      
      // Return the response with error details so BLoC can handle it properly
      return transferResponse;
    }
  }
}

