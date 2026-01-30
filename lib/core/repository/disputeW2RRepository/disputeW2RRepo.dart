import 'dart:convert';
import '../../const/assets_const.dart';
import '../../auth/httpClient.dart';
import '../../models/disputeW2RModels/disputeW2RModel.dart';

class DisputeW2RRepository {
  /// Create a dispute request
  Future<DisputeCreateResponse> createDispute({
    required String transactionId,
    String? remarks,
  }) async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/dispute/create/');

    final body = {
      'transaction_id': transactionId,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    };

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return DisputeCreateResponse.fromJson(data);
    } else {
      final errorMsg =
          data['error'] ??
          data['detail'] ??
          data['message'] ??
          'Failed to create dispute';
      throw Exception(errorMsg);
    }
  }

  /// Create a W2R request
  Future<W2RCreateResponse> createW2R({
    required String transactionId,
    required String rightAccountNo,
    String? remarks,
  }) async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/w2r/create/');

    final body = {
      'transaction_id': transactionId,
      'right_account_no': rightAccountNo,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    };

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return W2RCreateResponse.fromJson(data);
    } else {
      final errorMsg =
          data['error'] ??
          data['detail'] ??
          data['message'] ??
          'Failed to create W2R request';
      throw Exception(errorMsg);
    }
  }

  /// Approve or reject a dispute (Admin/Distributor only)
  Future<DisputeActionResponse> disputeAction({
    required int disputeId,
    required String action, // "accept" or "reject"
  }) async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/dispute/action/');

    final body = {'dispute_id': disputeId, 'action': action};

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return DisputeActionResponse.fromJson(data);
    } else {
      final errorMsg =
          data['error'] ??
          data['detail'] ??
          data['message'] ??
          'Failed to perform dispute action';
      throw Exception(errorMsg);
    }
  }

  /// Approve or reject a W2R request (Admin only)
  Future<W2RActionResponse> w2RAction({
    required int requestId,
    required String action, // "accept" or "reject"
    String? adminTransactionId,
    String? remarks,
  }) async {
    final url = Uri.parse('${AssetsConst.apiBase}api/android/w2r/action/');

    final body = {
      'request_id': requestId,
      'action': action,
      if (adminTransactionId != null && adminTransactionId.isNotEmpty)
        'admin_transaction_id': adminTransactionId,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    };

    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return W2RActionResponse.fromJson(data);
    } else {
      final errorMsg =
          data['error'] ??
          data['detail'] ??
          data['message'] ??
          'Failed to perform W2R action';
      throw Exception(errorMsg);
    }
  }
}
