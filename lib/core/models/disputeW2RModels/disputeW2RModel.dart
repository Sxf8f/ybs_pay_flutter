class DisputeCreateResponse {
  final bool success;
  final String message;
  final int disputeId;
  final String transactionId;
  final String refundStatus;

  DisputeCreateResponse({
    required this.success,
    required this.message,
    required this.disputeId,
    required this.transactionId,
    required this.refundStatus,
  });

  factory DisputeCreateResponse.fromJson(Map<String, dynamic> json) {
    return DisputeCreateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      disputeId: json['dispute_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      refundStatus: json['refund_status'] ?? '',
    );
  }
}

class W2RCreateResponse {
  final bool success;
  final String message;
  final int requestId;
  final String transactionId;
  final String status;
  final String statusDisplay;

  W2RCreateResponse({
    required this.success,
    required this.message,
    required this.requestId,
    required this.transactionId,
    required this.status,
    required this.statusDisplay,
  });

  factory W2RCreateResponse.fromJson(Map<String, dynamic> json) {
    return W2RCreateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      requestId: json['request_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
    );
  }
}

class DisputeActionResponse {
  final bool success;
  final String message;
  final int disputeId;
  final String transactionId;
  final String action;
  final String refundStatus;

  DisputeActionResponse({
    required this.success,
    required this.message,
    required this.disputeId,
    required this.transactionId,
    required this.action,
    required this.refundStatus,
  });

  factory DisputeActionResponse.fromJson(Map<String, dynamic> json) {
    return DisputeActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      disputeId: json['dispute_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      action: json['action'] ?? '',
      refundStatus: json['refund_status'] ?? '',
    );
  }
}

class W2RActionResponse {
  final bool success;
  final String message;
  final int requestId;
  final String transactionId;
  final String action;
  final String status;
  final String statusDisplay;
  final String? adminTransactionId;
  final String? remarks;

  W2RActionResponse({
    required this.success,
    required this.message,
    required this.requestId,
    required this.transactionId,
    required this.action,
    required this.status,
    required this.statusDisplay,
    this.adminTransactionId,
    this.remarks,
  });

  factory W2RActionResponse.fromJson(Map<String, dynamic> json) {
    return W2RActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      requestId: json['request_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      action: json['action'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      adminTransactionId: json['admin_transaction_id'],
      remarks: json['remarks'],
    );
  }
}
