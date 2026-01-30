class OperatorTypeCheckResponse {
  final bool hasActiveOperatorCheckApi;
  final int operatorTypeId;
  final String operatorTypeName;
  final String? operatorCheckApiPlaceholder;
  final OperatorCheckFieldConfig? fieldConfig;

  OperatorTypeCheckResponse({
    required this.hasActiveOperatorCheckApi,
    required this.operatorTypeId,
    required this.operatorTypeName,
    this.operatorCheckApiPlaceholder,
    this.fieldConfig,
  });

  factory OperatorTypeCheckResponse.fromJson(Map<String, dynamic> json) {
    return OperatorTypeCheckResponse(
      hasActiveOperatorCheckApi: json['has_active_operator_check_api'] ?? false,
      operatorTypeId: json['operator_type_id'] ?? 0,
      operatorTypeName: json['operator_type_name'] ?? '',
      operatorCheckApiPlaceholder: json['operator_check_api_placeholder'],
      fieldConfig: json['field_config'] != null
          ? OperatorCheckFieldConfig.fromJson(json['field_config'])
          : null,
    );
  }
}

class OperatorCheckFieldConfig {
  final String fieldName;
  final String fieldLabel;
  final String fieldType;
  final String placeholder;
  final bool isRequired;
  final int? minLength;
  final int? maxLength;
  final String? validationPattern;
  final String? helpText;

  OperatorCheckFieldConfig({
    required this.fieldName,
    required this.fieldLabel,
    required this.fieldType,
    required this.placeholder,
    required this.isRequired,
    this.minLength,
    this.maxLength,
    this.validationPattern,
    this.helpText,
  });

  factory OperatorCheckFieldConfig.fromJson(Map<String, dynamic> json) {
    return OperatorCheckFieldConfig(
      fieldName: json['field_name'] ?? '',
      fieldLabel: json['field_label'] ?? '',
      fieldType: json['field_type'] ?? 'text',
      placeholder: json['placeholder'] ?? '',
      isRequired: json['is_required'] ?? false,
      minLength: json['min_length'],
      maxLength: json['max_length'],
      validationPattern: json['validation_pattern'],
      helpText: json['help_text'],
    );
  }
}
