import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../const/assets_const.dart';
import '../../models/fundRequestModels/fundRequestModel.dart';
import '../../auth/httpClient.dart';
import '../../auth/tokenManager.dart';

class FundRequestRepository {
  /// Get fund request form data (banks, transfer modes, wallet types)
  Future<FundRequestFormDataResponse> getFormData() async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/android/fund-request/form-data/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FundRequestFormDataResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch form data');
    }
  }

  /// Get bank details by bank ID
  Future<BankDetailsResponse> getBankDetails(int bankId) async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/android/fund-request/bank-details/?bank_id=$bankId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BankDetailsResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch bank details');
    }
  }

  /// Submit fund request without receipt (JSON)
  Future<FundRequestSubmitResponse> submitFundRequest({
    required String amount,
    int? bankId,
    required int transferModeId,
    int? walletTypeId,
    String? accountHolder,
    required String accountNumber,
    String? ifscCode,
    String? branch,
    String? remark,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      'transfer_mode_id': transferModeId,
      'account_number': accountNumber,
    };

    if (bankId != null) body['bank_id'] = bankId;
    if (walletTypeId != null) body['wallet_type_id'] = walletTypeId;
    if (accountHolder != null && accountHolder.isNotEmpty) body['account_holder'] = accountHolder;
    if (ifscCode != null && ifscCode.isNotEmpty) body['ifsc_code'] = ifscCode;
    if (branch != null && branch.isNotEmpty) body['branch'] = branch;
    if (remark != null && remark.isNotEmpty) body['remark'] = remark;

    final response = await AuthenticatedHttpClient.post(
      Uri.parse('${AssetsConst.apiBase}api/android/fund-request/submit/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FundRequestSubmitResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to submit fund request');
    }
  }

  /// Submit fund request with receipt (multipart/form-data)
  Future<FundRequestSubmitResponse> submitFundRequestWithReceipt({
    required String amount,
    int? bankId,
    required int transferModeId,
    int? walletTypeId,
    String? accountHolder,
    required String accountNumber,
    String? ifscCode,
    String? branch,
    String? remark,
    required File receiptFile,
  }) async {
    // Get valid token (will auto-refresh if needed)
    final token = await AuthenticatedHttpClient.getToken();
    if (token == null) {
      throw Exception('No valid token available. Please login again.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AssetsConst.apiBase}api/android/fund-request/submit/'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['amount'] = amount;
    request.fields['transfer_mode_id'] = transferModeId.toString();
    request.fields['account_number'] = accountNumber;

    if (bankId != null) request.fields['bank_id'] = bankId.toString();
    if (walletTypeId != null) request.fields['wallet_type_id'] = walletTypeId.toString();
    if (accountHolder != null && accountHolder.isNotEmpty) request.fields['account_holder'] = accountHolder;
    if (ifscCode != null && ifscCode.isNotEmpty) request.fields['ifsc_code'] = ifscCode;
    if (branch != null && branch.isNotEmpty) request.fields['branch'] = branch;
    if (remark != null && remark.isNotEmpty) request.fields['remark'] = remark;

    request.files.add(
      await http.MultipartFile.fromPath(
        'receipt',
        receiptFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FundRequestSubmitResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      // Try to refresh token and retry once
      final refreshed = await TokenManager.refreshToken();
      if (refreshed) {
        final newToken = await AuthenticatedHttpClient.getToken();
        request.headers['Authorization'] = 'Bearer $newToken';
        final retryStreamedResponse = await request.send();
        final retryResponse = await http.Response.fromStream(retryStreamedResponse);
        if (retryResponse.statusCode == 200) {
          final data = json.decode(retryResponse.body);
          return FundRequestSubmitResponse.fromJson(data);
        }
      }
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Authentication failed. Please login again.');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to submit fund request');
    }
  }

  /// Get fund request history
  Future<FundRequestHistoryResponse> getFundRequestHistory({
    String? status,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('${AssetsConst.apiBase}api/android/fund-request/history/')
        .replace(queryParameters: queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FundRequestHistoryResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch fund request history');
    }
  }

  /// Get fund request details by ID
  Future<FundRequestDetailsResponse> getFundRequestDetails(int fundRequestId) async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/android/fund-request/$fundRequestId/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FundRequestDetailsResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch fund request details');
    }
  }
}
