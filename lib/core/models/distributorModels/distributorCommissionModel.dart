class CommissionSlabResponse {
  final bool success;
  final List<CommissionData> data;
  final String? commissionLabel;

  CommissionSlabResponse({
    required this.success,
    required this.data,
    this.commissionLabel,
  });

  factory CommissionSlabResponse.fromJson(Map<String, dynamic> json) {
    return CommissionSlabResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CommissionData.fromJson(e))
              .toList() ??
          (json['commission_data'] as List<dynamic>?)
              ?.map((e) => CommissionData.fromJson(e))
              .toList() ??
          [],
      commissionLabel: json['commission_label'],
    );
  }
}


class CommissionData {
  final String operatorId;
  final String operatorName;
  final String operatorType;
  final double commissionValue;
  final String commissionType;
  final String percentageOrFixed;
  final String? operatorIcon;

  CommissionData({
    required this.operatorId,
    required this.operatorName,
    required this.operatorType,
    required this.commissionValue,
    required this.commissionType,
    required this.percentageOrFixed,
    this.operatorIcon,
  });

  factory CommissionData.fromJson(Map<String, dynamic> json) {
    // Handle operator_icon - clean up double /media/ paths if present
    String? operatorIcon = json['operator_icon'];
    if (operatorIcon != null && operatorIcon.isNotEmpty) {
      // Fix double /media//media/ issue
      operatorIcon = operatorIcon.replaceAll('/media//media/', '/media/');
      // Ensure it starts with /media/ if it's a relative path
      if (!operatorIcon.startsWith('http') && !operatorIcon.startsWith('/media/')) {
        operatorIcon = '/media/$operatorIcon';
      }
    }
    
    return CommissionData(
      operatorId: (json['operatorID'] ?? json['operator_id'] ?? '').toString(),
      operatorName: json['operatorName'] ?? json['operator_name'] ?? '',
      operatorType: json['operatorType'] ?? json['operator_type'] ?? '',
      commissionValue: (json['commission_value'] is int)
          ? (json['commission_value'] as int).toDouble()
          : (json['commission_value'] is double)
              ? json['commission_value']
              : double.tryParse(json['commission_value'].toString()) ?? 0.0,
      commissionType: json['commission_type'] ?? 'Commission',
      percentageOrFixed: json['percentage_or_fixed'] ?? 'Percentage',
      operatorIcon: operatorIcon,
    );
  }
}

