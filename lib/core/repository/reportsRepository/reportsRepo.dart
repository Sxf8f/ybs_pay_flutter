import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../const/assets_const.dart';
import '../../models/reportModels/reportModel.dart';
import '../../auth/httpClient.dart';

class ReportsRepository {
  Future<http.Response> _makeRequest({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    String method = 'GET',
  }) async {
    final uri = Uri.parse('${AssetsConst.apiBase}api/android/reports/$endpoint')
        .replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
    
    http.Response response;
    
    if (method == 'POST') {
      response = await AuthenticatedHttpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
    } else {
      response = await AuthenticatedHttpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
    
    return response;
  }

  /// Get Recharge Report
  Future<RechargeReportResponse> getRechargeReport({
    int? operatorType,
    int? operator,
    int? status,
    int? criteria,
    String? search,
    String? startDate,
    String? endDate,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (operatorType != null) params['operator_type'] = operatorType;
    if (operator != null) params['operator'] = operator;
    if (status != null) params['status'] = status;
    if (criteria != null) params['criteria'] = criteria;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'recharge/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return RechargeReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch recharge report');
    }
  }

  /// Get Ledger Report
  Future<LedgerReportResponse> getLedgerReport({
    String? startDate,
    String? endDate,
    String? transactionId,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (transactionId != null && transactionId.isNotEmpty) params['transaction_id'] = transactionId;
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'ledger/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return LedgerReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch ledger report');
    }
  }

  /// Get Fund Order Report
  Future<FundOrderReportResponse> getFundOrderReport({
    int? status,
    int? transferMode,
    int? criteria,
    String? search,
    String? fromDate,
    String? toDate,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (transferMode != null) params['transfer_mode'] = transferMode;
    if (criteria != null) params['criteria'] = criteria;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (fromDate != null) params['from_date'] = fromDate;
    if (toDate != null) params['to_date'] = toDate;
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'fund-order/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return FundOrderReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch fund order report');
    }
  }

  /// Get Complaint Report
  Future<ComplaintReportResponse> getComplaintReport({
    String? refundStatus,
    int? operator,
    int? status,
    int? api,
    String? search,
    String? startDate,
    String? endDate,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (refundStatus != null) params['refund_status'] = refundStatus;
    if (operator != null) params['operator'] = operator;
    if (status != null) params['status'] = status;
    if (api != null) params['api'] = api;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'complaint/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return ComplaintReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch complaint report');
    }
  }

  /// Get Fund Debit Credit Report
  Future<FundDebitCreditReportResponse> getFundDebitCreditReport({
    int? walletType,
    bool? isSelf,
    int? receivedBy,
    String? type,
    String? mobile,
    String? startDate,
    String? endDate,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (walletType != null) params['wallet_type'] = walletType;
    if (isSelf != null) params['is_self'] = isSelf;
    if (receivedBy != null) params['received_by'] = receivedBy;
    if (type != null) params['type'] = type;
    if (mobile != null && mobile.isNotEmpty) params['mobile'] = mobile;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'fund-debit-credit/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return FundDebitCreditReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch fund debit credit report');
    }
  }

  /// Get User Daybook Report
  Future<UserDaybookReportResponse> getUserDaybookReport({
    String? phoneNumber,
    String? startDate,
    String? endDate,
    dynamic operator,
    bool? isDmt,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (phoneNumber != null && phoneNumber.isNotEmpty) params['phone_number'] = phoneNumber;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (operator != null) params['operator'] = operator.toString();
    if (isDmt != null) params['is_dmt'] = isDmt;
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'user-daybook/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return UserDaybookReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch user daybook report');
    }
  }

  /// Get Commission Slab Report
  Future<CommissionSlabReportResponse> getCommissionSlabReport({
    String? commissionId,
    int? operatorId,
    String? operatorType,
    String? search,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (commissionId != null && commissionId.isNotEmpty) params['commissionId'] = commissionId;
    if (operatorId != null) params['operator_id'] = operatorId;
    if (operatorType != null) params['operator_type'] = operatorType;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (limit != null) params['limit'] = limit;

    print('=== COMMISSION SLAB API REQUEST ===');
    print('Params: $params');

    final response = await _makeRequest(
      endpoint: 'commission-slab/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    print('=== COMMISSION SLAB API RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    final data = json.decode(response.body);
    
    print('=== RESPONSE DATA TYPES ===');
    if (data['data'] != null && data['data'] is List) {
      final dataList = data['data'] as List;
      if (dataList.isNotEmpty) {
        final firstItem = dataList[0];
        print('First item type: ${firstItem.runtimeType}');
        print('First item: $firstItem');
        print('commissionId type: ${firstItem['commissionId']?.runtimeType}, value: ${firstItem['commissionId']}');
        print('operatorName type: ${firstItem['operatorName']?.runtimeType}, value: ${firstItem['operatorName']}');
        print('operatorType type: ${firstItem['operatorType']?.runtimeType}, value: ${firstItem['operatorType']}');
        print('rt type: ${firstItem['rt']?.runtimeType}, value: ${firstItem['rt']}');
      }
    }
    
    if (response.statusCode == 200) {
      try {
        return CommissionSlabReportResponse.fromJson(data);
      } catch (e, stackTrace) {
        print('=== ERROR PARSING COMMISSION SLAB ===');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch commission slab report');
    }
  }

  /// Get W2R Report
  Future<W2RReportResponse> getW2RReport({
    String? status,
    String? transactionId,
    String? startDate,
    String? endDate,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (transactionId != null && transactionId.isNotEmpty) params['transaction_id'] = transactionId;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'w2r/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return W2RReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch W2R report');
    }
  }

  /// Get Daybook DMT Report
  Future<DaybookDMTReportResponse> getDaybookDMTReport({
    String? phoneNumber,
    String? startDate,
    String? endDate,
    dynamic operator,
    int? limit,
    bool usePost = false,
  }) async {
    final params = <String, dynamic>{};
    if (phoneNumber != null && phoneNumber.isNotEmpty) params['phone_number'] = phoneNumber;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (operator != null) params['operator'] = operator.toString();
    if (limit != null) params['limit'] = limit;

    final response = await _makeRequest(
      endpoint: 'daybook-dmt/',
      queryParams: usePost ? null : params,
      body: usePost ? params : null,
      method: usePost ? 'POST' : 'GET',
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return DaybookDMTReportResponse.fromJson(data);
    } else {
      throw Exception(data['error'] ?? data['detail'] ?? 'Failed to fetch daybook DMT report');
    }
  }
}
