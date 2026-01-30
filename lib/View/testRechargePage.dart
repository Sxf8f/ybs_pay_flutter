import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/sweet_alert_dialog.dart';
import 'package:ybs_pay/main.dart';
import '../core/const/assets_const.dart';
import '../core/const/color_const.dart';
import '../core/models/authModels/userModel.dart';
import '../core/models/appModels/operatorTypeCheckModel.dart';
import '../core/repository/securityRepository/securityRepo.dart';
import '../core/repository/appRepository/appRepo.dart';
import '../core/repository/operatorFormConfigRepository/operatorFormConfigRepo.dart';
import '../core/auth/tokenManager.dart';
import '../core/auth/httpClient.dart';
import 'widgets/secureKeyDialog.dart';
import 'confirmStatus/confirmStatusScreen.dart';
import '../core/bloc/userBloc/userBloc.dart';
import '../core/bloc/userBloc/userEvent.dart';
import '../core/bloc/userBloc/userState.dart';
import '../core/bloc/appBloc/appBloc.dart';
import '../core/bloc/appBloc/appState.dart';
import '../core/bloc/dashboardBloc/dashboardBloc.dart';
import '../core/bloc/dashboardBloc/dashboardEvent.dart';
import '../navigationPage.dart';

// Validation Result helper class
class _ValidationResult {
  final bool isValid;
  final String? errorMessage;
  _ValidationResult(this.isValid, this.errorMessage);
}

class RechargePage extends StatefulWidget {
  final LayoutModel layout;

  const RechargePage({super.key, required this.layout});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Map<String, TextEditingController> extraFieldControllers = {};
  bool isLoading = false; // Unified loading state for all operations

  // Helper functions for Sweet Alert dialogs
  Future<void> _showSuccessAlert(String message) async {
    await SweetAlert.show(
      context,
      title: "Success",
      subtitle: message,
      style: SweetAlertType.success,
    );
  }

  Future<void> _showErrorAlert(String message) async {
    await SweetAlert.show(
      context,
      title: "Error",
      subtitle: message,
      style: SweetAlertType.error,
    );
    // Navigate to home screen after error dialog is dismissed
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        try {
          // Refresh only balance and stats (preserves profile picture)
          // Use try-catch for each bloc access to handle cases where they might not be available
          try {
            final userBloc = context.read<UserBloc>();
            userBloc.add(const RefreshBalanceOnlyEvent());
          } catch (e) {
            print('⚠️ [RECHARGE_PAGE] UserBloc not available: $e');
          }

          try {
            final dashboardBloc = context.read<DashboardBloc>();
            dashboardBloc.add(FetchDashboardStatistics(period: 'month'));
          } catch (e) {
            print('⚠️ [RECHARGE_PAGE] DashboardBloc not available: $e');
          }

          print(
            '🔄 [RECHARGE_PAGE] Attempted to refresh balance and stats before navigation after error',
          );
        } catch (e) {
          print('⚠️ [RECHARGE_PAGE] Could not refresh home data: $e');
        }

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => navigationPage(initialIndex: 0),
          ),
        );
      }
    });
  }

  Future<void> _showWarningAlert(String message) async {
    await SweetAlert.show(
      context,
      title: "Warning",
      subtitle: message,
      style: SweetAlertType.warning,
    );
  }

  Future<void> _showInfoAlert(String message) async {
    await SweetAlert.show(
      context,
      title: "Info",
      subtitle: message,
      style: SweetAlertType.info,
    );
  }

  // Get operator name from operatorList
  String _getOperatorName() {
    if (selectedOperator != null && operatorList.isNotEmpty) {
      try {
        final operator = operatorList.firstWhere((op) {
          final id = (op['OperatorID'] is int)
              ? op['OperatorID'] as int
              : int.tryParse(op['OperatorID'].toString());
          return id == selectedOperator;
        }, orElse: () => null);
        if (operator != null) {
          return operator['OperatorName'] ??
              operator['OperatorName_DB'] ??
              widget.layout.operatorTypeName;
        }
      } catch (e) {
        print('Error getting operator name: $e');
      }
    }
    return widget.layout.operatorTypeName;
  }

  // Get operator image URL for a specific operator ID
  String? _getOperatorImageUrlById(int? operatorId) {
    if (operatorId != null && operatorList.isNotEmpty) {
      try {
        final operator = operatorList.firstWhere((op) {
          final id = (op['OperatorID'] is int)
              ? op['OperatorID'] as int
              : int.tryParse(op['OperatorID'].toString());
          return id == operatorId;
        }, orElse: () => null);
        if (operator != null) {
          // Check for icon field first (API format), then OperatorImageURL (legacy)
          final imageUrl = operator['icon'] ?? operator['OperatorImageURL'];
          if (imageUrl != null && imageUrl.toString().isNotEmpty) {
            String urlString = imageUrl.toString();
            // Prepend base URL if it's a relative path
            if (urlString.startsWith('/')) {
              return '${AssetsConst.apiBase}${urlString.substring(1)}';
            } else if (!urlString.startsWith('http')) {
              return '${AssetsConst.apiBase}$urlString';
            }
            return urlString;
          }
        }
      } catch (e) {
        print('Error getting operator image URL: $e');
      }
    }
    return null;
  }

  // Show confirmation dialog before payment
  Future<bool> _showConfirmationDialog({
    required String mobile,
    required String amount,
    String? planName,
    String? planAmount,
  }) async {
    final operatorName = _getOperatorName();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: colorConst.primaryColor1,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Confirm Payment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please verify the details before proceeding:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(Icons.phone, 'Mobile Number', mobile),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.business, 'Operator', operatorName),
                    if (planName != null && planName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.list_alt, 'Plan', planName),
                    ],
                    if (planAmount != null && planAmount.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.account_balance_wallet,
                        'Plan Amount',
                        '₹$planAmount',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.currency_rupee,
                      'Amount',
                      '₹$amount',
                      isAmount: true,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorConst.primaryColor1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorConst.primaryColor1,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Total amount to be debited: ₹$amount',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorConst.primaryColor1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorConst.primaryColor1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Confirm & Pay',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isAmount = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isAmount ? colorConst.primaryColor1 : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
                  color: isAmount ? colorConst.primaryColor1 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> operatorList = [];
  int? selectedOperator;
  bool isFetchingOperator = false;
  bool isOperatorFetched = false;

  // Operator type check API state
  OperatorTypeCheckResponse? operatorTypeCheckResponse;
  bool hasOperatorCheck = false;
  OperatorCheckFieldConfig? operatorCheckFieldConfig;

  // Operator form config state
  LayoutModel? operatorFormConfig;

  // Track if mobile field from operator form config should be skipped (when initial field has value)
  bool skipMobileFieldFromConfig = false;
  String? initialMobileFieldName;
  bool isLoadingOperatorConfig = false;

  // Bill information state
  BillInfo? billInfo;
  bool isBillFetched = false;

  // DTH specific state
  DthInfo? dthInfo;
  DthPlans? dthPlans;
  bool isDthInfoFetched = false;
  bool isDthPlansFetched = false;
  bool isDthHeavyRefreshLoading = false;
  String? selectedPlanAmount;
  String? selectedPlanName;

  // Offers/Plans state
  List<dynamic> offers = [];
  bool isOffersLoading = false;
  bool isOffersFetched = false;
  String? currentOffersLabel;

  // Categorized plans state (for display_format: "categorized")
  Map<String, List<dynamic>> categorizedPlans = {};
  List<String> planCategories = [];
  bool isCategorizedPlans = false;

  // Control visibility of plans/offers section (hide after selection for better UX)
  bool showPlansOffers = true;

  @override
  void initState() {
    super.initState();
    print('🚀 [INIT_STATE] START');
    print(
      '   📋 widget.layout.operatorTypeId: ${widget.layout.operatorTypeId}',
    );
    print('   🔘 widget.layout.paymentButton: ${widget.layout.paymentButton}');
    print(
      '   📋 widget.layout.fields count: ${widget.layout.fields?.length ?? 0}',
    );

    // Check operator type API on initialization
    print('   🔄 Calling _checkOperatorTypeApi()...');
    _checkOperatorTypeApi();

    // Auto operator detection listener
    mobileController.addListener(() {
      print(
        '🔘 [MOBILE_CONTROLLER_LISTENER] Text: ${mobileController.text}, length: ${mobileController.text.length}',
      );
      if (mobileController.text.length == 10 &&
          widget.layout.autoOperator?.enabled == true) {
        print(
          '   ✅ Mobile length is 10 and autoOperator enabled, calling fetchAutoOperator()...',
        );
        fetchAutoOperator();
      }
    });

    // Pre-fetch dropdown operators if enabled
    if (widget.layout.operatorDropdown?.enabled == true) {
      print(
        '   🔄 Operator dropdown enabled, calling fetchOperatorDropdown()...',
      );
      fetchOperatorDropdown();
    }

    // Initialize extra field controllers
    print('   🔄 Calling _initializeFieldControllers()...');
    _initializeFieldControllers();
    print('🚀 [INIT_STATE] END');
  }

  void _initializeFieldControllers() {
    print('🔧 [_initializeFieldControllers] START');
    final fields = _getCurrentFields();
    print('   📋 Fields to initialize: ${fields.length}');
    for (var field in fields) {
      final name = field['name'] ?? '';
      if (name.isNotEmpty && !extraFieldControllers.containsKey(name)) {
        extraFieldControllers[name] = TextEditingController();
        print('   ✅ Initialized controller for field: "$name"');
      } else if (name.isNotEmpty) {
        print('   ⏭️ Controller already exists for field: "$name"');
      }
    }
    print('   📊 Total controllers: ${extraFieldControllers.length}');
    print('🔧 [_initializeFieldControllers] END');
  }

  Future<void> _checkOperatorTypeApi() async {
    try {
      final appRepo = AppRepository();
      final response = await appRepo.checkOperatorTypeApi(
        widget.layout.operatorTypeId,
      );

      setState(() {
        operatorTypeCheckResponse = response;
        hasOperatorCheck = response.hasActiveOperatorCheckApi;
        operatorCheckFieldConfig = response.fieldConfig;
      });

      // If operator check is enabled and field config exists, initialize controller
      if (hasOperatorCheck && operatorCheckFieldConfig != null) {
        final fieldName = operatorCheckFieldConfig!.fieldName;
        if (fieldName.isNotEmpty &&
            !extraFieldControllers.containsKey(fieldName)) {
          extraFieldControllers[fieldName] = TextEditingController();
        }
      }
    } catch (e) {
      print('Error checking operator type API: $e');
      // Continue without operator check if API fails
      setState(() {
        hasOperatorCheck = false;
      });
    }
  }

  // Get current fields (ONLY from operator form config when operator is selected)
  // Initially (before operator selection), return empty list - no dynamic fields should show
  // Only show operator check field + dropdown initially, then all fields from operatorFormConfig after selection
  List<dynamic> _getCurrentFields() {
    // Only return fields if operator form config is available (operator has been selected/fetched)
    if (operatorFormConfig != null) {
      return operatorFormConfig!.fields ?? [];
    }
    // Return empty list - no dynamic fields should show until operator is selected
    return [];
  }

  // Helper to prefill amount in both controllers
  void _prefillAmount(String amount) {
    amountController.text = amount;
    if (extraFieldControllers.containsKey('amount')) {
      extraFieldControllers['amount']!.text = amount;
    }
    setState(() {
      selectedPlanAmount = amount;
      // Hide plans/offers section after selection for better UX (Pay button visible without scrolling)
      showPlansOffers = false;
    });
  }

  // Validate a single field based on its configuration
  _ValidationResult _validateField(dynamic field, String? value) {
    final fieldName = field['name']?.toString() ?? '';
    final fieldLabel =
        field['label']?.toString() ?? field['hint']?.toString() ?? fieldName;
    final fieldType = field['type']?.toString() ?? 'text';
    final isRequired = field['required'] == true;
    final validation = field['validation'] ?? {};

    // Required check
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return _ValidationResult(false, "$fieldLabel is required");
    }

    // If field is optional and empty, it's valid
    if (value == null || value.trim().isEmpty) {
      return _ValidationResult(true, null);
    }

    final trimmedValue = value.trim();

    // Length checks (for text fields)
    final minLength = validation['min_length'];
    final maxLength = validation['max_length'];

    if (minLength != null && trimmedValue.length < minLength) {
      return _ValidationResult(
        false,
        "$fieldLabel must be at least $minLength characters",
      );
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return _ValidationResult(
        false,
        "$fieldLabel must not exceed $maxLength characters",
      );
    }

    // Value checks (for number fields)
    if (fieldType == 'number') {
      final numValue = double.tryParse(trimmedValue);
      if (numValue == null) {
        return _ValidationResult(false, "$fieldLabel must be a valid number");
      }

      final minValue = validation['min_value'];
      final maxValue = validation['max_value'];

      if (minValue != null && numValue < minValue) {
        return _ValidationResult(
          false,
          "$fieldLabel must be at least $minValue",
        );
      }

      if (maxValue != null && numValue > maxValue) {
        return _ValidationResult(
          false,
          "$fieldLabel must not exceed $maxValue",
        );
      }
    }

    // Pattern/Regex validation
    final pattern = validation['pattern'];
    if (pattern != null && pattern.toString().isNotEmpty) {
      try {
        final regex = RegExp(pattern.toString());
        if (!regex.hasMatch(trimmedValue)) {
          return _ValidationResult(false, "$fieldLabel format is invalid");
        }
      } catch (e) {
        print('⚠️ Invalid regex pattern: $pattern');
      }
    }

    return _ValidationResult(true, null);
  }

  // Validate account number (mobile/consumer number) based on operator-level validations
  _ValidationResult _validateAccountNumber(
    String accountNumber,
    dynamic operatorValidations,
  ) {
    if (operatorValidations == null) {
      return _ValidationResult(true, null);
    }

    final accountLengthMin = operatorValidations['account_length_min'];
    final accountLengthMax = operatorValidations['account_length_max'];
    final accountMustBeNumeric =
        operatorValidations['account_must_be_numeric'] == true;
    final accountName =
        operatorValidations['account_name']?.toString() ?? 'Account number';

    // Length check
    if (accountLengthMin != null && accountLengthMax != null) {
      if (accountNumber.length < accountLengthMin ||
          accountNumber.length > accountLengthMax) {
        return _ValidationResult(
          false,
          "$accountName must be $accountLengthMin digits.",
        );
      }
    }

    // Numeric check
    if (accountMustBeNumeric) {
      if (!accountNumber
          .split('')
          .every((char) => RegExp(r'[0-9]').hasMatch(char))) {
        return _ValidationResult(false, "$accountName must be numeric.");
      }
    }

    return _ValidationResult(true, null);
  }

  // Validate amount based on operator-level validations
  _ValidationResult _validateAmount(
    double amount,
    dynamic operatorValidations,
  ) {
    if (operatorValidations == null) {
      return _ValidationResult(true, null);
    }

    final amountMin = operatorValidations['amount_min'];
    final amountMax = operatorValidations['amount_max'];

    if (amountMin != null && amountMax != null) {
      if (amount < amountMin || amount > amountMax) {
        return _ValidationResult(
          false,
          "Amount must be between $amountMin and $amountMax.",
        );
      }
    }

    return _ValidationResult(true, null);
  }

  // Validate all form fields
  Map<String, String> _validateAllFields() {
    final errors = <String, String>{};
    final layout = _getCurrentLayout();
    final fields = layout.fields ?? [];
    // Get operator_validations from layout (may be in operatorFormConfig or widget.layout)
    dynamic operatorValidations;
    if (operatorFormConfig != null &&
        operatorFormConfig is Map<String, dynamic>) {
      final configMap = operatorFormConfig as Map<String, dynamic>;
      operatorValidations = configMap['operator_validations'];
    } else {
      operatorValidations = layout.operatorValidations;
    }

    // Validate each field
    for (var field in fields) {
      final fieldName = field['name']?.toString() ?? '';
      String? fieldValue;

      // Get value from appropriate controller
      if (fieldName == 'mobile' &&
          hasOperatorCheck &&
          operatorCheckFieldConfig != null) {
        // Use operator check field value
        final checkFieldName = operatorCheckFieldConfig!.fieldName;
        if (extraFieldControllers.containsKey(checkFieldName)) {
          fieldValue = extraFieldControllers[checkFieldName]!.text;
        } else if (hasOperatorCheck) {
          fieldValue = mobileController.text;
        }
      } else if (extraFieldControllers.containsKey(fieldName)) {
        fieldValue = extraFieldControllers[fieldName]!.text;
      } else if (fieldName == 'amount') {
        // Check both amountController and extraFieldControllers
        fieldValue = amountController.text;
        if (fieldValue.isEmpty && extraFieldControllers.containsKey('amount')) {
          fieldValue = extraFieldControllers['amount']!.text;
        }
      }

      // Validate field
      final result = _validateField(field, fieldValue);
      if (!result.isValid) {
        errors[fieldName] = result.errorMessage ?? 'Invalid value';
      }
    }

    // Validate account number (mobile/consumer) with operator-level validations
    final accountNumber = _getMobileFromForm();
    if (accountNumber.isNotEmpty) {
      final accountResult = _validateAccountNumber(
        accountNumber,
        operatorValidations,
      );
      if (!accountResult.isValid) {
        // Find the account field name
        final accountFieldName =
            hasOperatorCheck && operatorCheckFieldConfig != null
            ? operatorCheckFieldConfig!.fieldName
            : 'mobile';
        errors[accountFieldName] =
            accountResult.errorMessage ?? 'Invalid account number';
      }
    }

    // Validate amount with operator-level validations
    String amountStr = amountController.text.trim();
    if (amountStr.isEmpty && extraFieldControllers.containsKey('amount')) {
      amountStr = extraFieldControllers['amount']!.text.trim();
    }
    if (amountStr.isNotEmpty) {
      final amount = double.tryParse(amountStr);
      if (amount != null) {
        final amountResult = _validateAmount(amount, operatorValidations);
        if (!amountResult.isValid) {
          errors['amount'] = amountResult.errorMessage ?? 'Invalid amount';
        }
      }
    }

    return errors;
  }

  // Get mobile/consumer number from form (as per documentation pattern)
  // Priority 1: Operator check API field name
  // Priority 2: Initial mobile field (if operator check enabled)
  // Priority 3: Common field names (mobile, consumer, number, tel, consumer_number)
  String _getMobileFromForm() {
    // Priority 1: Use operator check API field name
    if (hasOperatorCheck && operatorCheckFieldConfig != null) {
      final fieldName = operatorCheckFieldConfig!.fieldName;
      if (fieldName.isNotEmpty &&
          extraFieldControllers.containsKey(fieldName)) {
        final value = extraFieldControllers[fieldName]!.text.trim();
        if (value.isNotEmpty) {
          print(
            '📱 [_getMobileFromForm] Found in operator check field "$fieldName": $value',
          );
          return value;
        }
      }
    }

    // Priority 2: Try initial mobile field (if operator check enabled)
    if (hasOperatorCheck) {
      final value = mobileController.text.trim();
      if (value.isNotEmpty) {
        print('📱 [_getMobileFromForm] Found in initial mobile field: $value');
        return value;
      }
    }

    // Priority 3: Try common field names
    final commonNames = [
      'mobile',
      'consumer',
      'number',
      'tel',
      'consumer_number',
    ];
    for (final name in commonNames) {
      if (extraFieldControllers.containsKey(name)) {
        final value = extraFieldControllers[name]!.text.trim();
        if (value.isNotEmpty) {
          print('📱 [_getMobileFromForm] Found in field "$name": $value');
          return value;
        }
      }
    }

    // Fallback: Try mobileController
    final value = mobileController.text.trim();
    if (value.isNotEmpty) {
      print('📱 [_getMobileFromForm] Found in mobileController: $value');
      return value;
    }

    print('⚠️ [_getMobileFromForm] No mobile value found in any field');
    return '';
  }

  // Get amount from form (supports both hardcoded amountController and dynamic amount field)
  String _getAmountFromForm() {
    // Priority 1: hardcoded amountController (used when amount isn't in API fields)
    final hardcoded = amountController.text.trim();
    if (hardcoded.isNotEmpty) return hardcoded;

    // Priority 2: dynamic controllers for common amount keys
    const commonAmountNames = ['amount', 'Amount'];
    for (final name in commonAmountNames) {
      final controller = extraFieldControllers[name];
      if (controller != null) {
        final v = controller.text.trim();
        if (v.isNotEmpty) return v;
      }
    }

    return '';
  }

  // Get visible fields based on flow control and sort by display_order
  List<dynamic> _getVisibleFields() {
    final allFields = _getCurrentFields();
    List<dynamic> visibleFields = [];

    for (var field in allFields) {
      bool shouldShow = true;

      // Check show_after_operator_fetch
      if (field['show_after_operator_fetch'] == true && !isOperatorFetched) {
        shouldShow = false;
      }

      // Check show_after_bill_fetch
      if (field['show_after_bill_fetch'] == true && !isBillFetched) {
        shouldShow = false;
      }

      // Skip operator check field if operator check is not enabled
      if (field['name'] == operatorCheckFieldConfig?.fieldName &&
          !hasOperatorCheck) {
        shouldShow = false;
      }

      if (shouldShow) {
        visibleFields.add(field);
      }
    }

    // Sort by display_order
    visibleFields.sort((a, b) {
      int orderA = a['display_order'] ?? 999;
      int orderB = b['display_order'] ?? 999;
      return orderA.compareTo(orderB);
    });

    return visibleFields;
  }

  // Get current layout (operator form config if available, otherwise layout)
  LayoutModel _getCurrentLayout() {
    final layout = operatorFormConfig ?? widget.layout;
    if (operatorFormConfig != null) {
      print('📋 [_getCurrentLayout] Using operatorFormConfig');
      print(
        '   🔘 paymentButton: ${layout.paymentButton}, type: ${layout.paymentButton.runtimeType}',
      );
    } else {
      print('📋 [_getCurrentLayout] Using widget.layout');
      print(
        '   🔘 paymentButton: ${layout.paymentButton}, type: ${layout.paymentButton.runtimeType}',
      );
    }
    return layout;
  }

  // Get bill fetch mode
  String? _getBillFetchMode() {
    final layout = _getCurrentLayout();
    final mode = layout.billFetchMode ?? 'both';
    print(
      '📋 [_getBillFetchMode] layout.billFetchMode: ${layout.billFetchMode}, returning: "$mode"',
    );
    return mode;
  }

  // Check if bill fetch is required first
  bool _getRequireBillFetchFirst() {
    return _getCurrentLayout().requireBillFetchFirst ?? false;
  }

  // Check if amount is editable after fetch
  bool _getAmountEditableAfterFetch() {
    final layout = _getCurrentLayout();
    // Check new API structure first (editable_after_fetch)
    if (layout.amount?.editableAfterFetch != null) {
      return layout.amount!.editableAfterFetch!;
    }
    // Fallback to old structure or default
    return layout.amountEditableAfterFetch ?? true;
  }

  // Check if amount field is editable based on bill fetch mode and state
  // IMPORTANT: This implements the correct logic from the documentation
  // BEFORE bill fetch: Always editable (if visible)
  // AFTER bill fetch: Check bill_fetch_mode and editable_after_fetch
  bool _isAmountEditable() {
    print(
      '🔘🔘🔘 [_isAmountEditable] START - Checking amount field editability',
    );

    final layout = _getCurrentLayout();
    final billFetchMode = _getBillFetchMode();
    final amountConfig = layout.amount;

    print('   📊 Current State:');
    print('      - isBillFetched: $isBillFetched');
    print(
      '      - billFetchMode: "$billFetchMode" (type: ${billFetchMode.runtimeType})',
    );
    print('      - amountConfig: ${amountConfig != null ? "SET" : "NULL"}');
    if (amountConfig != null) {
      print('      - amountConfig.enabled: ${amountConfig.enabled}');
      print('      - amountConfig.editable: ${amountConfig.editable}');
      print(
        '      - amountConfig.editableAfterFetch: ${amountConfig.editableAfterFetch}',
      );
      print(
        '      - amountConfig.initialEditable: ${amountConfig.initialEditable}',
      );
    }
    print('      - layout.billFetchMode: ${layout.billFetchMode}');
    print(
      '      - layout.requireBillFetchFirst: ${layout.requireBillFetchFirst}',
    );
    print(
      '      - layout.amountEditableAfterFetch: ${layout.amountEditableAfterFetch}',
    );

    // Get initial_editable (should always be true unless require_bill_fetch_first hides it)
    final initialEditable = amountConfig?.initialEditable ?? true;
    print('      - initialEditable (computed): $initialEditable');

    // BEFORE BILL FETCH: Check bill_fetch_mode
    // If bill_fetch_mode is "fetch_only", amount should be non-editable (can only come from bill fetch)
    // Otherwise, use initialEditable setting
    if (!isBillFetched) {
      if (billFetchMode == "fetch_only") {
        print(
          '   ✅ BEFORE bill fetch: fetch_only mode - returning false (non-editable, must fetch bill first)',
        );
        print(
          '🔘🔘🔘 [_isAmountEditable] END - Result: false (BEFORE FETCH, fetch_only mode)',
        );
        return false; // Non-editable in fetch_only mode before bill fetch
      }
      print(
        '   ✅ BEFORE bill fetch: returning initialEditable=$initialEditable',
      );
      print(
        '🔘🔘🔘 [_isAmountEditable] END - Result: $initialEditable (BEFORE FETCH)',
      );
      return initialEditable; // Use initialEditable for other modes
    }

    // AFTER BILL FETCH: Check mode and settings
    final editableAfterFetch = _getAmountEditableAfterFetch();

    print('   ✅ AFTER bill fetch:');
    print('      - editableAfterFetch (computed): $editableAfterFetch');
    print('      - billFetchMode: "$billFetchMode"');

    // Switch based on bill_fetch_mode
    bool result;
    switch (billFetchMode) {
      case "fetch_only":
        // Always read-only after fetch (regardless of editable_after_fetch)
        result = false;
        print('   → fetch_only mode: returning false (read-only)');
        break;

      case "manual_only":
        // Always editable (no bill fetch button, so this shouldn't happen after fetch)
        result = true;
        print('   → manual_only mode: returning true (always editable)');
        break;

      case "both":
        // Use editable_after_fetch setting
        result = editableAfterFetch;
        print(
          '   → both mode: returning editableAfterFetch=$editableAfterFetch',
        );
        break;

      default:
        // Default to editable
        result = true;
        print(
          '   ⚠️ default mode (unexpected billFetchMode="$billFetchMode"): returning true',
        );
        break;
    }

    print(
      '🔘🔘🔘 [_isAmountEditable] END - Result: $result (AFTER FETCH, mode: $billFetchMode)',
    );
    return result;
  }

  Future<void> fetchOperatorFormConfig(int operatorId) async {
    print('🔧 [FETCH_OPERATOR_FORM_CONFIG] START - operatorId: $operatorId');
    try {
      setState(() {
        isLoadingOperatorConfig = true;
      });
      print('   ⏳ Set isLoadingOperatorConfig = true');

      final operatorFormConfigRepo = OperatorFormConfigRepository();
      print('   📡 Calling repository.fetchOperatorFormConfig($operatorId)...');
      final config = await operatorFormConfigRepo.fetchOperatorFormConfig(
        operatorId,
      );

      print('   ✅ Received config from repository');
      print('   📋 Config fields count: ${config.fields?.length ?? 0}');
      print('   🔘 paymentButton: ${config.paymentButton}');

      // Debug: Print amount and bill fetch settings from API
      print('   💰 Amount Config from API:');
      print('      - amount?.enabled: ${config.amount?.enabled}');
      print('      - amount?.editable: ${config.amount?.editable}');
      print(
        '      - amount?.editableAfterFetch: ${config.amount?.editableAfterFetch}',
      );
      print(
        '      - amount?.initialEditable: ${config.amount?.initialEditable}',
      );
      print('   📋 Bill Fetch Settings from API:');
      print(
        '      - billFetchMode: "${config.billFetchMode}" (type: ${config.billFetchMode.runtimeType})',
      );
      print('      - requireBillFetchFirst: ${config.requireBillFetchFirst}');
      print(
        '      - amountEditableAfterFetch: ${config.amountEditableAfterFetch}',
      );
      print('   🔘 Fetch Bill Button Settings from API:');
      print(
        '      - fetchBillButton: ${config.fetchBillButton} (type: ${config.fetchBillButton.runtimeType})',
      );
      print(
        '      - fetchBillEndpoint: "${config.fetchBillEndpoint}" (empty: ${config.fetchBillEndpoint.isEmpty})',
      );

      if (config.fields != null && config.fields!.isNotEmpty) {
        print('   📝 Fields list:');
        for (var i = 0; i < config.fields!.length; i++) {
          final field = config.fields![i];
          print(
            '      [${i + 1}] name: ${field['name']}, hint: ${field['hint']}, show_after_operator_fetch: ${field['show_after_operator_fetch']}',
          );
        }
      }

      // Note: Skip logic is handled in build method, not here
      // This ensures it's evaluated during rendering based on current state

      setState(() {
        operatorFormConfig = config;
        isLoadingOperatorConfig = false;
        // Reset bill fetched state when new operator config is loaded
        isBillFetched = false;
        billInfo = null;
        // Reset plans/offers visibility when operator changes (show again for new operator)
        showPlansOffers = true;
        print(
          '   🔄 Reset isBillFetched=false, billInfo=null when loading new operator config',
        );
      });
      print('   ✅ Set operatorFormConfig and isLoadingOperatorConfig = false');

      // Debug: Check amount editability after setting config
      print(
        '   🔘 Amount editability check after config load: ${_isAmountEditable()}',
      );

      // Re-initialize field controllers with new fields
      print('   🔄 Re-initializing field controllers...');
      _initializeFieldControllers();
      print('   ✅ Field controllers re-initialized');

      // Reset skip flag after rendering (per web logic)
      // Note: Reset happens in build method after field rendering

      print('🔧 [FETCH_OPERATOR_FORM_CONFIG] SUCCESS');
    } catch (e, stackTrace) {
      print('❌ [FETCH_OPERATOR_FORM_CONFIG] ERROR: $e');
      print('   Stack trace: $stackTrace');
      setState(() {
        isLoadingOperatorConfig = false;
        operatorFormConfig = null; // Clear config on error
      });
      print('   ⚠️ Cleared operatorFormConfig on error');
      // Continue with layout config if operator config fails
    } finally {
      // Ensure loading is always cleared
      if (isLoadingOperatorConfig) {
        setState(() {
          isLoadingOperatorConfig = false;
        });
      }
    }
  }

  Future<void> fetchOperatorDropdown() async {
    print('11a');
    try {
      final endpoint = widget.layout.operatorDropdown?.endpoint ?? "";
      print(widget.layout.operatorDropdown?.endpoint);
      print(endpoint);
      if (endpoint.isEmpty) return;
      print('121a');

      final url = Uri.parse(
        "${AssetsConst.apiBase}$endpoint".replaceAll(
          "{OPERATORTYPEID}",
          widget.layout.operatorTypeId.toString(),
        ),
      );

      print(url);
      print(widget.layout.operatorTypeId.toString());

      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        debugPrint("No access token found for operator dropdown");
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          operatorList = data['operators'] ?? [];
        });
      }
    } catch (e) {
      print('223');
      debugPrint("Dropdown error: $e");
    }
  }

  Future<void> fetchAutoOperatorFromCheckField(String mobileValue) async {
    print(
      '🔍 [FETCH_AUTO_OPERATOR_FROM_CHECK_FIELD] START - mobile: $mobileValue',
    );
    try {
      setState(() => isFetchingOperator = true);
      print('   ⏳ Set isFetchingOperator = true');

      // Use operator-info API with operator_type_id
      final operatorInfoUrl = Uri.parse(
        "${AssetsConst.apiBase}api/android/operator-info/?mobile=$mobileValue&operator_type_id=${widget.layout.operatorTypeId}",
      );
      print('   📡 Operator Info URL: $operatorInfoUrl');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      print('   🔑 Token available: ${token != null && token.isNotEmpty}');

      if (token != null && token.isNotEmpty) {
        final headers = {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        };

        print('   📡 Making GET request to operator-info...');
        final operatorInfoResponse = await http.get(
          operatorInfoUrl,
          headers: headers,
        );
        print('   📊 Response status: ${operatorInfoResponse.statusCode}');

        if (operatorInfoResponse.statusCode == 200) {
          final data = json.decode(operatorInfoResponse.body);
          print('   ✅ Response data: $data');
          final operatorId =
              data['operator_id'] ??
              data['OperatorID'] ??
              data['_mapped_operator_id'];
          print('   🔍 Extracted operatorId: $operatorId');

          if (operatorId != null) {
            final opId = (operatorId is int)
                ? operatorId
                : int.tryParse(operatorId.toString());
            print('   🔢 Parsed operatorId: $opId');

            if (opId != null) {
              setState(() {
                selectedOperator = opId;
                isOperatorFetched = true;
              });
              print(
                '   ✅ Set selectedOperator = $opId, isOperatorFetched = true',
              );

              // Update mobile controller if operator check field is mobile
              if (operatorCheckFieldConfig?.fieldName == 'mobile') {
                mobileController.text = mobileValue;
                print('   📱 Updated mobileController.text = $mobileValue');
              }

              // Fetch operator form config when operator is detected
              // Keep isFetchingOperator = true to show inline loader during config fetch
              print('   🔄 Calling fetchOperatorFormConfig($opId)...');
              await fetchOperatorFormConfig(opId);
              print('   ✅ fetchOperatorFormConfig completed');
              print('🔍 [FETCH_AUTO_OPERATOR_FROM_CHECK_FIELD] SUCCESS');
              // Clear isFetchingOperator after config is fetched
              setState(() => isFetchingOperator = false);
              return;
            }
          } else {
            print('   ⚠️ No operatorId found in response');
          }
        }
      } else {
        print('   ⚠️ No token available, skipping operator-info API');
      }

      // Fallback to legacy auto-operator endpoint
      final endpoint = widget.layout.autoOperator?.endpoint ?? "";
      print('   🔄 Falling back to legacy endpoint: $endpoint');
      if (endpoint.isNotEmpty) {
        final url = Uri.parse(
          "${AssetsConst.apiBase}$endpoint".replaceAll("{MOBILE}", mobileValue),
        );
        print('   📡 Legacy URL: $url');

        final response = await http.get(url);
        print('   📊 Legacy response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('   ✅ Legacy response data: $data');
          final operatorId =
              data['operator_id'] ??
              data['OperatorID'] ??
              data['_mapped_operator_id'];
          print('   🔍 Extracted operatorId: $operatorId');

          if (operatorId != null) {
            final opId = (operatorId is int)
                ? operatorId
                : int.tryParse(operatorId.toString());
            print('   🔢 Parsed operatorId: $opId');

            if (opId != null) {
              setState(() {
                selectedOperator = opId;
                isOperatorFetched = true;
              });
              print(
                '   ✅ Set selectedOperator = $opId, isOperatorFetched = true',
              );

              // Update mobile controller if operator check field is mobile
              if (operatorCheckFieldConfig?.fieldName == 'mobile') {
                mobileController.text = mobileValue;
                print('   📱 Updated mobileController.text = $mobileValue');
              }

              // Fetch operator form config when operator is detected
              // Keep isFetchingOperator = true to show inline loader during config fetch
              print('   🔄 Calling fetchOperatorFormConfig($opId)...');
              await fetchOperatorFormConfig(opId);
              print('   ✅ fetchOperatorFormConfig completed');
              print(
                '🔍 [FETCH_AUTO_OPERATOR_FROM_CHECK_FIELD] SUCCESS (legacy)',
              );
              // Clear isFetchingOperator after config is fetched
              setState(() => isFetchingOperator = false);
              return;
            }
          }
        }
      } else {
        print('   ⚠️ No legacy endpoint available');
      }
    } catch (e, stackTrace) {
      print('❌ [FETCH_AUTO_OPERATOR_FROM_CHECK_FIELD] ERROR: $e');
      print('   Stack trace: $stackTrace');
    } finally {
      // Only clear if not already cleared (in case of early return)
      if (isFetchingOperator) {
        setState(() => isFetchingOperator = false);
        print('   ✅ Set isFetchingOperator = false (finally)');
      }
      print('🔍 [FETCH_AUTO_OPERATOR_FROM_CHECK_FIELD] END');
    }
  }

  Future<void> fetchAutoOperator() async {
    print('🔍 [FETCH_AUTO_OPERATOR] START - mobile: ${mobileController.text}');
    try {
      setState(() => isFetchingOperator = true);
      print('   ⏳ Set isFetchingOperator = true');

      final endpoint = widget.layout.autoOperator?.endpoint ?? "";
      print('   📡 Auto operator endpoint: $endpoint');
      if (endpoint.isEmpty) {
        print('   ⚠️ Endpoint is empty, returning');
        return;
      }

      final url = Uri.parse(
        "${AssetsConst.apiBase}$endpoint".replaceAll(
          "{MOBILE}",
          mobileController.text,
        ),
      );
      print('   📡 Legacy URL: $url');

      // Try new operator-info endpoint first with operator_type_id
      try {
        final operatorInfoUrl = Uri.parse(
          "${AssetsConst.apiBase}api/android/operator-info/?mobile=${mobileController.text}&operator_type_id=${widget.layout.operatorTypeId}",
        );
        print('   📡 Operator Info URL: $operatorInfoUrl');

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        print('   🔑 Token available: ${token != null && token.isNotEmpty}');

        if (token != null && token.isNotEmpty) {
          final headers = {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          };

          print('   📡 Making GET request to operator-info...');
          final operatorInfoResponse = await http.get(
            operatorInfoUrl,
            headers: headers,
          );
          print('   📊 Response status: ${operatorInfoResponse.statusCode}');

          if (operatorInfoResponse.statusCode == 200) {
            final data = json.decode(operatorInfoResponse.body);
            print('   ✅ Response data: $data');
            final operatorId =
                data['operator_id'] ??
                data['OperatorID'] ??
                data['_mapped_operator_id'];
            print('   🔍 Extracted operatorId: $operatorId');

            if (operatorId != null) {
              final opId = (operatorId is int)
                  ? operatorId
                  : int.tryParse(operatorId.toString());
              print('   🔢 Parsed operatorId: $opId');

              if (opId != null) {
                setState(() {
                  selectedOperator = opId;
                  isOperatorFetched = true;
                });
                print(
                  '   ✅ Set selectedOperator = $opId, isOperatorFetched = true',
                );

                // Fetch operator form config when operator is detected
                // Keep isFetchingOperator = true to show inline loader during config fetch
                print('   🔄 Calling fetchOperatorFormConfig($opId)...');
                await fetchOperatorFormConfig(opId);
                print('   ✅ fetchOperatorFormConfig completed');
                print('🔍 [FETCH_AUTO_OPERATOR] SUCCESS');
                // Clear isFetchingOperator after config is fetched
                setState(() => isFetchingOperator = false);
                return;
              }
            } else {
              print('   ⚠️ No operatorId found in response');
            }
          }
        } else {
          print('   ⚠️ No token available, skipping operator-info API');
        }
      } catch (e, stackTrace) {
        print('❌ Operator-info endpoint failed: $e');
        print('   Stack trace: $stackTrace');
        print('   🔄 Falling back to legacy endpoint...');
      }

      // Fallback to legacy auto-operator endpoint
      print('   📡 Making GET request to legacy endpoint...');
      final response = await http.get(url);
      print('   📊 Legacy response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('   ✅ Legacy response data: $data');
        final operatorId =
            data['operator_id'] ??
            data['OperatorID'] ??
            data['_mapped_operator_id'];
        print('   🔍 Extracted operatorId: $operatorId');

        if (operatorId != null) {
          final opId = (operatorId is int)
              ? operatorId
              : int.tryParse(operatorId.toString());
          print('   🔢 Parsed operatorId: $opId');

          if (opId != null) {
            setState(() {
              selectedOperator = opId;
              isOperatorFetched = true;
            });
            print(
              '   ✅ Set selectedOperator = $opId, isOperatorFetched = true',
            );

            // Fetch operator form config when operator is detected
            // Keep isFetchingOperator = true to show inline loader during config fetch
            print('   🔄 Calling fetchOperatorFormConfig($opId)...');
            await fetchOperatorFormConfig(opId);
            print('   ✅ fetchOperatorFormConfig completed');
            print('🔍 [FETCH_AUTO_OPERATOR] SUCCESS (legacy)');
            // Clear isFetchingOperator after config is fetched
            setState(() => isFetchingOperator = false);
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ [FETCH_AUTO_OPERATOR] ERROR: $e');
      print('   Stack trace: $stackTrace');
    } finally {
      // Only clear if not already cleared (in case of early return or error)
      if (isFetchingOperator) {
        setState(() => isFetchingOperator = false);
        print('   ✅ Set isFetchingOperator = false (finally)');
      }
      print('🔍 [FETCH_AUTO_OPERATOR] END');
    }
  }

  // performBooking() and performRequest() methods removed - buttons are not functional

  Future<void> performRecharge() async {
    // Payment endpoint: Always use /api/android/recharge/payment/ (like web)
    // Backend handles API switching internally during payment processing
    final endpoint = _getCurrentLayout().paymentEndpoint.isNotEmpty
        ? _getCurrentLayout().paymentEndpoint
        : '/api/android/recharge/payment/'; // Default payment endpoint (always available)

    // ⚠️ IMPORTANT: Get mobile from form using helper function (checks all possible fields)
    final mobile = _getMobileFromForm();

    // Get amount from both sources (hardcoded field or dynamic field)
    String amount = amountController.text.trim();
    if (amount.isEmpty && extraFieldControllers.containsKey('amount')) {
      amount = extraFieldControllers['amount']!.text.trim();
    }

    // Get operator ID
    final operatorId =
        selectedOperator?.toString() ?? widget.layout.operatorTypeId.toString();

    // Validate operator
    if (operatorId.isEmpty) {
      _showWarningAlert("Please select an operator");
      return;
    }

    // Validate amount (required by backend)
    if (amount.isEmpty) {
      _showWarningAlert("Please enter amount");
      return;
    }

    // ⚠️ COMPREHENSIVE VALIDATION: Validate all fields before submission
    final validationErrors = _validateAllFields();
    if (validationErrors.isNotEmpty) {
      // Show first validation error
      final firstError = validationErrors.values.first;
      _showWarningAlert(firstError);
      return;
    }

    // Check if bill fetch is required first
    if (_getRequireBillFetchFirst() && !isBillFetched) {
      _showWarningAlert(
        "Please fetch bill first before proceeding with payment",
      );
      return;
    }

    // Check secure key status
    String? secureKey;
    try {
      final securityRepo = SecurityRepository();
      final secureKeyStatus = await securityRepo.checkSecureKeyStatus();

      if (secureKeyStatus.requiresSecureKey) {
        // Show secure key input dialog
        secureKey = await showDialog<String>(
          context: context,
          builder: (context) => SecureKeyDialog(
            title: 'Enter Secure Key',
            message:
                'Please enter your secure key (pin password) to complete the recharge',
          ),
        );

        if (secureKey == null || secureKey.isEmpty) {
          // User cancelled secure key input
          return;
        }
      }
    } catch (e) {
      print('Error checking secure key status: $e');
      // Continue without secure key if check fails
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      mobile: mobile,
      amount: amount,
      planName: selectedPlanName,
      planAmount: selectedPlanAmount,
    );

    if (!confirmed) {
      return; // User cancelled
    }

    setState(() => isLoading = true);

    try {
      // 🔹 Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        _showErrorAlert("Login expired. Please log in again.");
        return;
      }

      // Use booking endpoint (unified API as per documentation)
      final url = Uri.parse("${AssetsConst.apiBase}$endpoint");

      // 🔹 Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      // 🔹 Build request body with ALL form fields (as per unified API documentation)
      // The backend will automatically map fields to API placeholders
      final body = <String, dynamic>{"operator": operatorId, "amount": amount};

      // Add mobile if available (some operators use consumer_number instead)
      if (mobile.isNotEmpty) {
        body["mobile"] = mobile;
      }

      // Add ALL extra form fields (consumer_number, date_of_birth, etc.)
      // Backend will automatically map them to API placeholders
      extraFieldControllers.forEach((key, controller) {
        final value = controller.text.trim();
        // Only add non-empty values (backend handles required field validation)
        if (value.isNotEmpty) {
          body[key] = value;
        }
      });

      // Add secure key if provided
      if (secureKey != null && secureKey.isNotEmpty) {
        body["secure_key"] = secureKey;
      }

      print('💳 [PERFORM_RECHARGE] Request body: $body');
      print('   📱 Mobile: $mobile');
      print('   💰 Amount: $amount');
      print('   🔢 Operator: $operatorId');
      print('   📋 Extra fields count: ${extraFieldControllers.length}');

      // final response = await http.post(url, body: body);
      // final response = await http.post(url, body: body, headers: headers);

      // 🔹 Send POST request (encode as JSON)
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body), // ✅ convert map → JSON string
      );

      // Handle 401 Unauthorized - token might be expired
      if (response.statusCode == 401) {
        print('Received 401 Unauthorized, attempting token refresh...');
        final refreshed = await TokenManager.refreshToken();

        if (refreshed) {
          print('Token refreshed successfully, retrying request...');
          // Retry with new token
          final newToken = await TokenManager.getAccessToken();
          if (newToken != null) {
            headers['Authorization'] = 'Bearer $newToken';
            response = await http.post(
              url,
              headers: headers,
              body: jsonEncode(body),
            );
          } else {
            // Token refresh failed, show error
            setState(() => isLoading = false);
            _showErrorAlert("Session expired. Please login again.");
            return;
          }
        } else {
          // Token refresh failed, show error
          setState(() => isLoading = false);
          _showErrorAlert("Session expired. Please login again.");
          return;
        }
      }

      final data = json.decode(response.body);
      print('💳 [PERFORM_RECHARGE] Response status: ${response.statusCode}');
      print('💳 [PERFORM_RECHARGE] Response data: $data');

      // Handle errors (400, 401, 500, etc.)
      if (response.statusCode != 200) {
        final errorMsg = data['message'] ?? 'Payment failed';
        setState(() => isLoading = false);

        // Check if secure key is required
        if (data['requires_secure_key'] == true) {
          _showErrorAlert(
            data['message'] ?? 'Secure key is required for this transaction',
          );
          return;
        }

        _showErrorAlert(errorMsg);
        return;
      }

      // Check for secure key errors in success response
      if (data['requires_secure_key'] == true) {
        setState(() => isLoading = false);
        _showErrorAlert(
          data['message'] ?? 'Secure key is required for this transaction',
        );
        return;
      }

      // Check if payment was successful
      if (data['success'] == true || data['ok'] == true) {
        final transactionId = data['transaction_id'] ?? '';
        final status = data['status'] ?? 'SUCCESS';

        print(
          '✅ [PERFORM_RECHARGE] Success - Transaction ID: $transactionId, Status: $status',
        );
        print('   💬 Message: ${data['message'] ?? 'Recharge successful'}');

        // Navigate to success screen with amount
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => confirmStatus(amount: amount),
          ),
        );
      } else {
        // Show error message from backend
        final errorMsg = data['message'] ?? 'Recharge failed';
        setState(() => isLoading = false);
        _showErrorAlert(errorMsg);
      }
    } catch (e) {
      print("Error: $e");
      _showErrorAlert("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchBill() async {
    if (_getCurrentLayout().fetchBillEndpoint.isEmpty) return;

    // ⚠️ IMPORTANT: Get mobile from form using helper function (checks all possible fields)
    final mobile = _getMobileFromForm();
    final operator =
        selectedOperator?.toString() ?? widget.layout.operatorTypeId.toString();

    // ⚠️ CRITICAL: Validate mobile BEFORE calling API (backend returns 400, but client should validate first)
    if (mobile.isEmpty || mobile.trim().isEmpty) {
      _showWarningAlert("Please enter mobile/consumer number to fetch bill");
      return; // STOP - Don't call API
    }

    // Validate operator
    if (operator.isEmpty) {
      _showWarningAlert("Please select an operator");
      return; // STOP - Don't call API
    }

    // Clean mobile value
    final cleanMobile = mobile.trim();

    setState(() => isLoading = true);
    try {
      // 🔹 Build API URL - Support both path parameters (recommended) and query parameters
      // Option 1: Path parameters (recommended): /api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/
      // Option 2: Query parameters (alternative): /api/android/recharge/fetch-bill/?mobile={MOBILE}&operator={OPERATOR}
      // Build URL with path parameters (recommended by backend)
      // Use Uri.encodeComponent to properly encode mobile value
      final pathUrl =
          "${AssetsConst.apiBase}api/android/recharge/fetch-bill/${Uri.encodeComponent(cleanMobile)}/$operator/";
      final url = Uri.parse(pathUrl);

      print('🔍 [FETCH_BILL] URL: $url');
      print('   📱 Mobile: $cleanMobile (length: ${cleanMobile.length})');
      print('   🔢 Operator: $operator');

      // 🔹 Call API using AuthenticatedHttpClient (handles SSL, token refresh, and timeouts)
      final resp = await AuthenticatedHttpClient.get(url);
      print('🔍 [FETCH_BILL] Response status: ${resp.statusCode}');
      print('🔍 [FETCH_BILL] Response body: ${resp.body}');

      final data = json.decode(resp.body);

      // 🔹 Handle errors (backend now returns 400 with clear messages instead of 404)
      if (resp.statusCode == 400 || resp.statusCode == 404) {
        final errorMsg = data['message'] ?? 'Failed to fetch bill';
        setState(() => isLoading = false);
        _showErrorAlert(errorMsg);
        return;
      }

      // 🔹 Parse bill information
      if (resp.statusCode == 200 && data['success'] == true) {
        // Extract amount from response BEFORE creating billInfo
        final billAmount = data['amount']?.toString() ?? '';

        setState(() {
          billInfo = BillInfo.fromJson(data);
          final oldBillFetched = isBillFetched;
          isBillFetched = true;
          print(
            '🔘🔘🔘 [FETCH_BILL] Set isBillFetched = true (was: $oldBillFetched)',
          );
          print('   📊 Current billFetchMode: "${_getBillFetchMode()}"');
          print(
            '   📊 Layout billFetchMode: "${_getCurrentLayout().billFetchMode}"',
          );
          print(
            '   📊 Amount editable check BEFORE setState: ${_isAmountEditable()}',
          );

          // Prefill amount field with bill amount (if amount field exists for operator)
          if (billAmount.isNotEmpty) {
            // Prefill in amountController (hardcoded amount field)
            amountController.text = billAmount;
            print('📝 [FETCH_BILL] Prefilled amountController: $billAmount');

            // Prefill in extraFieldControllers['amount'] if amount field exists in operator form config
            if (extraFieldControllers.containsKey('amount')) {
              extraFieldControllers['amount']!.text = billAmount;
              print(
                '📝 [FETCH_BILL] Prefilled extraFieldControllers["amount"]: $billAmount',
              );
            }
          }

          // Clear selected plan since amount comes from bill
          selectedPlanAmount = null;
          selectedPlanName = null;
          // Clear offers when fetching bill
          offers = [];
          isOffersFetched = false;
          // Show plans/offers section again (user might want to select a different plan)
          showPlansOffers = true;
        });

        // Check after setState completes
        print(
          '   📊 Amount editable check AFTER setState: ${_isAmountEditable()}',
        );
        print('   📊 isBillFetched state: $isBillFetched');

        _showSuccessAlert("Bill fetched successfully");

        // Amount field editability is handled by _isAmountEditable() method
        // It checks bill_fetch_mode and amount_editable_after_fetch automatically
        // - If bill_fetch_mode == "fetch_only": amount is always non-editable
        // - If amount_editable_after_fetch == false: amount becomes non-editable after fetch
      } else {
        // Handle error response from backend
        final errorMsg = data['message'] ?? 'Failed to fetch bill';
        _showErrorAlert(errorMsg);
      }
    } catch (e) {
      print('❌ [FETCH_BILL] Exception: $e');
      // Show user-friendly error message
      final errorMsg =
          e.toString().contains('SocketException') ||
              e.toString().contains('TimeoutException')
          ? 'Network error. Please check your connection and try again.'
          : 'Failed to fetch bill: ${e.toString()}';
      _showErrorAlert(errorMsg);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPlans(String url, String label) async {
    setState(() {
      isLoading = true;
      isOffersLoading = true;
      isOffersFetched = false;
      offers = [];
      categorizedPlans = {};
      planCategories = [];
      isCategorizedPlans = false;
      currentOffersLabel = label;
      // Clear DTH plans when fetching new plans/offers
      dthPlans = null;
      isDthPlansFetched = false;
      // Show plans/offers section again when button is clicked (allows user to change selection)
      showPlansOffers = true;
    });

    try {
      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        _showErrorAlert("Login expired. Please log in again.");
        setState(() {
          isLoading = false;
          isOffersLoading = false;
        });
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      print('📡 [FETCH_PLANS] Calling: $url');
      final resp = await http.get(Uri.parse(url), headers: headers);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        print(
          '📡 [FETCH_PLANS] Response received: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}',
        );

        // NEW UNIFIED API FORMAT: {success: true, data: {...}, display_format: "categorized"/"flat"/"simple"}
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];
          final displayFormat = data['display_format']?.toString() ?? 'flat';
          final categories = data['categories'] as List<dynamic>?;

          print(
            '📡 [FETCH_PLANS] display_format: $displayFormat, categories: $categories',
          );

          if (displayFormat == 'categorized' && responseData is Map) {
            // CATEGORIZED FORMAT: {category1: [...], category2: [...]}
            Map<String, List<dynamic>> categorized = {};
            List<String> cats = [];

            if (categories != null && categories.isNotEmpty) {
              // Use provided categories order
              for (var cat in categories) {
                final catName = cat.toString();
                if (responseData.containsKey(catName) &&
                    responseData[catName] is List) {
                  categorized[catName] = List<dynamic>.from(
                    responseData[catName],
                  );
                  cats.add(catName);
                }
              }
            } else {
              // Extract categories from data keys
              responseData.forEach((key, value) {
                if (value is List) {
                  categorized[key.toString()] = List<dynamic>.from(value);
                  cats.add(key.toString());
                }
              });
            }

            // Check if any plan has amount_options (DTH plans with multiple durations)
            bool hasAmountOptions = false;
            for (var category in categorized.keys) {
              final plans = categorized[category] ?? [];
              for (var plan in plans) {
                if (plan is Map && plan['amount_options'] != null) {
                  hasAmountOptions = true;
                  break;
                }
              }
              if (hasAmountOptions) break;
            }

            if (hasAmountOptions) {
              // DTH plans format with amount_options - convert to DthPlans model
              Map<String, List<DthPlan>> records = {};
              categorized.forEach((category, plans) {
                for (var plan in plans) {
                  if (plan is Map && plan['amount_options'] != null) {
                    final amountOptions =
                        plan['amount_options'] as Map<String, dynamic>;
                    for (var entry in amountOptions.entries) {
                      final duration = entry.key;
                      final amount = entry.value.toString();
                      if (!records.containsKey(duration)) {
                        records[duration] = [];
                      }
                      records[duration]!.add(
                        DthPlan(
                          rs: {duration: amount},
                          desc: plan['description']?.toString() ?? '',
                          planName: plan['plan_name']?.toString() ?? '',
                          lastUpdate: '',
                        ),
                      );
                    }
                  }
                }
              });
              setState(() {
                dthPlans = DthPlans(records: records, status: 1);
                isDthPlansFetched = true;
                isLoading = false;
                isOffersFetched = false;
                offers = [];
                categorizedPlans = {};
                isCategorizedPlans = false;
                showPlansOffers = true; // Show plans section when fetched
              });
            } else {
              // Regular categorized plans/offers
              setState(() {
                categorizedPlans = categorized;
                planCategories = cats;
                isCategorizedPlans = true;
                isOffersFetched = false;
                offers = [];
                isLoading = false;
                isOffersLoading = false;
                dthPlans = null;
                isDthPlansFetched = false;
                showPlansOffers = true; // Show plans section when fetched
              });
            }
          } else if (displayFormat == 'flat' && responseData is List) {
            // FLAT FORMAT: Simple array/list
            setState(() {
              offers = List<dynamic>.from(responseData);
              isOffersFetched = true;
              isLoading = false;
              categorizedPlans = {};
              isCategorizedPlans = false;
              dthPlans = null;
              isDthPlansFetched = false;
              showPlansOffers = true; // Show plans section when fetched
            });
          } else if (responseData is List) {
            // Fallback: treat as flat list
            // Check if it's DTH plans format with amount_options
            if (responseData.isNotEmpty &&
                responseData[0] is Map &&
                responseData[0]['amount_options'] != null) {
              // DTH plans format: [{plan_name: "...", amount_options: {...}}]
              Map<String, List<DthPlan>> records = {};
              for (var plan in responseData) {
                if (plan is Map && plan['amount_options'] != null) {
                  final amountOptions =
                      plan['amount_options'] as Map<String, dynamic>;
                  for (var entry in amountOptions.entries) {
                    final duration = entry.key;
                    final amount = entry.value.toString();
                    if (!records.containsKey(duration)) {
                      records[duration] = [];
                    }
                    records[duration]!.add(
                      DthPlan(
                        rs: {duration: amount},
                        desc: plan['description']?.toString() ?? '',
                        planName: plan['plan_name']?.toString() ?? '',
                        lastUpdate: '',
                      ),
                    );
                  }
                }
              }
              setState(() {
                dthPlans = DthPlans(records: records, status: 1);
                isDthPlansFetched = true;
                isLoading = false;
                isOffersFetched = false;
                offers = [];
                categorizedPlans = {};
                isCategorizedPlans = false;
                showPlansOffers = true; // Show plans section when fetched
              });
            } else {
              // Regular flat list
              setState(() {
                offers = List<dynamic>.from(responseData);
                isOffersFetched = true;
                isLoading = false;
                isOffersLoading = false;
                categorizedPlans = {};
                isCategorizedPlans = false;
                dthPlans = null;
                isDthPlansFetched = false;
              });
            }
          } else if (responseData is Map) {
            // Single object response - convert to list for display
            setState(() {
              offers = [responseData];
              isOffersFetched = true;
              isLoading = false;
              categorizedPlans = {};
              isCategorizedPlans = false;
              dthPlans = null;
              isDthPlansFetched = false;
              showPlansOffers = true; // Show plans section when fetched
            });
          } else {
            // Unknown format - show error
            setState(() {
              isLoading = false;
            });
            _showErrorAlert("Unknown response format for $label");
          }
        }
        // BACKWARD COMPATIBILITY: Handle old format {records: [...]}
        else if (data['records'] != null) {
          if (data['records'] is Map && !(data['records'] is List)) {
            // Old DTH plans format (Map structure)
            setState(() {
              dthPlans = DthPlans.fromJson(data);
              isDthPlansFetched = true;
              isLoading = false;
              isOffersLoading = false;
              isOffersFetched = false;
              offers = [];
              categorizedPlans = {};
              showPlansOffers = true; // Show plans section when fetched
              isCategorizedPlans = false;
            });
          } else if (data['records'] is List) {
            // Old regular plans/offers format (List structure)
            setState(() {
              offers = List<dynamic>.from(data['records']);
              isOffersFetched = true;
              isLoading = false;
              isOffersLoading = false;
              categorizedPlans = {};
              isCategorizedPlans = false;
              dthPlans = null;
              showPlansOffers = true; // Show plans section when fetched
              isDthPlansFetched = false;
            });
          } else {
            setState(() {
              isLoading = false;
              isOffersLoading = false;
            });
            _showErrorAlert("Failed to parse $label data");
          }
        } else {
          setState(() {
            isLoading = false;
            isOffersLoading = false;
          });
          _showErrorAlert("No data received for $label");
        }
      } else {
        setState(() {
          isLoading = false;
          isOffersLoading = false;
        });
        _showErrorAlert("Failed to load $label (Status: ${resp.statusCode})");
      }
    } catch (e) {
      print('❌ [FETCH_PLANS] Error: $e');
      setState(() {
        isLoading = false;
        isOffersLoading = false;
      });
      _showErrorAlert("Failed to load $label: ${e.toString()}");
    } finally {
      // Ensure loading is always cleared, even if setState fails
      if (isLoading || isOffersLoading) {
        setState(() {
          isLoading = false;
          isOffersLoading = false;
        });
      }
    }
  }

  Future<void> fetchDthInfo(String url) async {
    try {
      setState(() => isLoading = true);

      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        setState(() => isLoading = false);
        _showErrorAlert("Login expired. Please log in again.");
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final resp = await http.get(Uri.parse(url), headers: headers);

      print('🔍 [FETCH_DTH_INFO] Response status: ${resp.statusCode}');
      print('🔍 [FETCH_DTH_INFO] Response body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        print('🔍 [FETCH_DTH_INFO] Parsed data keys: ${data.keys.toList()}');
        print('🔍 [FETCH_DTH_INFO] Full response: $data');

        // Get mobile from form (could be in different fields)
        final mobile = _getMobileFromForm();
        print('🔍 [FETCH_DTH_INFO] Mobile from form: "$mobile"');

        // Get operator name from selected operator or layout
        final operatorName = _getOperatorName();
        print('🔍 [FETCH_DTH_INFO] Operator name: "$operatorName"');

        Map<String, dynamic> dthInfoData;

        // NEW UNIFIED API FORMAT: {success: true, data: {...}}
        if (data['success'] == true && data['data'] != null) {
          print('🔍 [FETCH_DTH_INFO] Detected new unified API format');
          print('   - data[data] type: ${data['data']?.runtimeType}');
          print('   - data[data] content: ${data['data']}');

          // data['data'] is a single Map object with DTH info, wrap it in a list for records
          final dataContent = data['data'] as Map<String, dynamic>;

          dthInfoData = {
            'tel': mobile.isNotEmpty
                ? mobile
                : (dataContent['tel']?.toString() ?? ''),
            'operator': operatorName.isNotEmpty
                ? operatorName
                : (dataContent['operator']?.toString() ??
                      widget.layout.operatorTypeName),
            'records': [dataContent], // Wrap single record in list
            'status':
                data['status'] ??
                (dataContent['status'] is int ? dataContent['status'] : 1),
          };
        }
        // BACKWARD COMPATIBILITY: Handle old format {tel, operator, records, status}
        else if (data['tel'] != null || data['records'] != null) {
          print(
            '🔍 [FETCH_DTH_INFO] Detected old format (backward compatibility)',
          );
          dthInfoData = Map<String, dynamic>.from(data);

          // Ensure records is a list
          if (dthInfoData['records'] != null &&
              dthInfoData['records'] is! List) {
            dthInfoData['records'] = [dthInfoData['records']];
          }
        } else {
          print('❌ [FETCH_DTH_INFO] Invalid response format');
          print('   - Response keys: ${data.keys.toList()}');
          print('   - Full response: $data');
          setState(() => isLoading = false);
          _showErrorAlert(
            "Invalid DTH info response format. Please check logs.",
          );
          return;
        }

        print('🔍 [FETCH_DTH_INFO] Final dthInfoData:');
        print('   - tel: ${dthInfoData['tel']}');
        print('   - operator: ${dthInfoData['operator']}');
        print('   - records: ${dthInfoData['records']}');
        print('   - records type: ${dthInfoData['records']?.runtimeType}');
        final recordsList = dthInfoData['records'] as List?;
        print('   - records length: ${recordsList?.length ?? 0}');
        print('   - status: ${dthInfoData['status']}');

        if (recordsList != null && recordsList.isNotEmpty) {
          print(
            '   - First record keys: ${(recordsList[0] as Map).keys.toList()}',
          );
          print('   - First record: ${recordsList[0]}');
        } else {
          print('   ⚠️ WARNING: records list is empty!');
        }

        try {
          setState(() {
            dthInfo = DthInfo.fromJson(dthInfoData);
            isDthInfoFetched = true;
          });

          print('✅ [FETCH_DTH_INFO] DthInfo created successfully');
          print('   - dthInfo.operator: ${dthInfo?.operator}');
          print('   - dthInfo.tel: ${dthInfo?.tel}');
          print('   - dthInfo.records.length: ${dthInfo?.records.length}');
          if (dthInfo?.records.isNotEmpty == true) {
            final firstRecord = dthInfo!.records[0];
            print(
              '   - First record customerName: "${firstRecord.customerName}"',
            );
            print('   - First record planName: "${firstRecord.planName}"');
            print('   - First record balance: "${firstRecord.balance}"');
            print(
              '   - First record monthlyRecharge: "${firstRecord.monthlyRecharge}"',
            );
            print('   - First record status: "${firstRecord.status}"');
            print(
              '   - First record nextRechargeDate: "${firstRecord.nextRechargeDate}"',
            );
          } else {
            print('   ⚠️ WARNING: dthInfo.records is empty!');
          }

          _showSuccessAlert("DTH Info fetched successfully");
          setState(() => isLoading = false);
        } catch (e, stackTrace) {
          print('❌ [FETCH_DTH_INFO] Error creating DthInfo: $e');
          print('   Stack trace: $stackTrace');
          setState(() => isLoading = false);
          _showErrorAlert("Error parsing DTH info: $e");
        }
      } else {
        print('❌ [FETCH_DTH_INFO] Failed with status: ${resp.statusCode}');
        setState(() => isLoading = false);
        _showErrorAlert(
          "Failed to fetch DTH info (Status: ${resp.statusCode})",
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorAlert("DTH Info error: $e");
    } finally {
      // Ensure loading is always cleared
      if (isLoading) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> performDthHeavyRefresh(String url) async {
    try {
      setState(() => isLoading = true);

      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        setState(() => isLoading = false);
        _showErrorAlert("Login expired. Please log in again.");
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final resp = await http.get(Uri.parse(url), headers: headers);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        // NEW UNIFIED API FORMAT: {success: true, data: {...}}
        if (data['success'] == true && data['data'] != null) {
          // Extract message and customer name from response
          Map<String, dynamic> responseData = data['data'];

          // Handle if data is array (get first item)
          if (responseData is List && responseData.isNotEmpty) {
            responseData = responseData[0];
          }

          String message =
              responseData['desc'] ??
              responseData['description'] ??
              'Heavy refresh request sent successfully';
          String customerName =
              responseData['customerName'] ??
              responseData['customer_name'] ??
              '';

          // Display success dialog with customer name and message
          String successMessage = message;
          if (customerName.isNotEmpty) {
            successMessage = "Customer: $customerName\n\n$message";
          }

          _showSuccessAlert(successMessage);
          setState(() => isLoading = false);
        }
        // BACKWARD COMPATIBILITY: Handle old format
        else if (data['tel'] != null || data['records'] != null) {
          final refreshData = DthHeavyRefresh.fromJson(data);
          String message =
              refreshData.records.desc ??
              'Heavy refresh request sent successfully';
          String customerName = refreshData.records.customerName ?? '';

          String successMessage = message;
          if (customerName.isNotEmpty) {
            successMessage = "Customer: $customerName\n\n$message";
          }

          _showSuccessAlert(successMessage);
          setState(() => isLoading = false);
        } else {
          setState(() => isLoading = false);
          _showErrorAlert("Invalid heavy refresh response format");
        }
      } else {
        setState(() => isLoading = false);
        _showErrorAlert("Failed to perform heavy refresh");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorAlert("Heavy refresh error: $e");
    } finally {
      // Ensure loading is always cleared
      if (isLoading) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showPlansDialog(dynamic data, String label) {
    // Handle new unified API format: {success: true, data: [...]}
    dynamic records;
    if (data['success'] == true && data['data'] != null) {
      records = data['data'];
    } else if (data['records'] != null) {
      // Backward compatibility with old format
      records = data['records'];
    } else if (data['data'] != null) {
      // Fallback: try data key directly
      records = data['data'];
    }

    // Normalize plans into either a Map<String, List> (grouped) or List
    List<Widget> items = [];

    if (records == null) {
      // No records found
      items.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('No plans/offers available'),
        ),
      );
    } else if (records is Map) {
      // grouped records (key -> list) - DTH plans format
      records.forEach((group, list) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              group.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        if (list is List) {
          for (var plan in list) {
            // Handle both 'amount' and 'rs' fields
            final amount =
                plan['amount']?.toString() ?? plan['rs']?.toString() ?? '';
            final desc =
                plan['desc']?.toString() ??
                plan['description']?.toString() ??
                '';
            final validity = plan['validity']?.toString() ?? '';

            items.add(
              ListTile(
                title: Text(amount.isNotEmpty ? "₹$amount" : "N/A"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (desc.isNotEmpty) Text(desc),
                    if (validity.isNotEmpty && validity != "N/A")
                      Text(
                        "Validity: $validity",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                trailing: amount.isNotEmpty
                    ? ElevatedButton(
                        onPressed: () {
                          amountController.text = amount;
                          selectedPlanAmount = amount;
                          selectedPlanName = desc.isNotEmpty ? desc : "Plan";
                          Navigator.pop(context);
                          _showInfoAlert("Plan Selected: ₹$amount");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorConst.primaryColor1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          "Choose",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                    : null,
                onTap: amount.isNotEmpty
                    ? () {
                        amountController.text = amount;
                        selectedPlanAmount = amount;
                        selectedPlanName = desc.isNotEmpty ? desc : "Plan";
                        Navigator.pop(context);
                        _showInfoAlert("Plan Selected: ₹$amount");
                      }
                    : null,
              ),
            );
            items.add(const Divider());
          }
        }
      });
    } else if (records is List) {
      // Offers/Plans format - records is a List
      for (var plan in records) {
        // Handle new DTH plans format with amount_options
        if (plan is Map && plan['amount_options'] != null) {
          // New DTH plan format: {plan_name: "...", amount_options: {...}}
          final planName = plan['plan_name']?.toString() ?? '';
          final description = plan['description']?.toString() ?? '';
          final amountOptions = plan['amount_options'] as Map<String, dynamic>;

          items.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                planName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
          if (description.isNotEmpty) {
            items.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(description),
              ),
            );
          }

          // Show each amount option
          amountOptions.forEach((duration, amount) {
            items.add(
              ListTile(
                title: Text("₹${amount.toString()} - $duration"),
                subtitle: Text("Plan: $planName"),
                onTap: () {
                  amountController.text = amount.toString();
                  selectedPlanAmount = amount.toString();
                  selectedPlanName = "$planName ($duration)";
                  Navigator.pop(context);
                },
              ),
            );
            items.add(const Divider());
          });
        } else {
          // Regular plan/offer format: Check both 'amount' and 'rs' fields
          // For plans: prefer 'amount' field
          // For offers: prefer 'rs' field (DTH), then 'amount' field
          final amount =
              plan['amount']?.toString() ?? plan['rs']?.toString() ?? '';
          final desc =
              plan['desc']?.toString() ?? plan['description']?.toString() ?? '';
          final validity = plan['validity']?.toString() ?? '';

          items.add(
            ListTile(
              title: Text(amount.isNotEmpty ? "₹$amount" : "N/A"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (desc.isNotEmpty) Text(desc),
                  if (validity.isNotEmpty && validity != "N/A")
                    Text(
                      "Validity: $validity",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              trailing: amount.isNotEmpty
                  ? ElevatedButton(
                      onPressed: () {
                        amountController.text = amount;
                        selectedPlanAmount = amount;
                        selectedPlanName = desc.isNotEmpty ? desc : "Plan";
                        Navigator.pop(context);
                        _showInfoAlert("Plan Selected: ₹$amount");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorConst.primaryColor1,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        "Choose",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : null,
              onTap: amount.isNotEmpty
                  ? () {
                      amountController.text = amount;
                      selectedPlanAmount = amount;
                      selectedPlanName = desc.isNotEmpty ? desc : "Plan";
                      Navigator.pop(context);
                      _showInfoAlert("Plan Selected: ₹$amount");
                    }
                  : null,
            ),
          );
          items.add(const Divider());
        }
      }
    } else if (data is List) {
      // Direct list format
      for (var plan in data) {
        // Handle both 'amount' and 'rs' fields
        final amount =
            plan['amount']?.toString() ?? plan['rs']?.toString() ?? '';
        final desc =
            plan['desc']?.toString() ?? plan['description']?.toString() ?? '';
        final validity = plan['validity']?.toString() ?? '';

        items.add(
          ListTile(
            title: Text(amount.isNotEmpty ? "₹$amount" : "N/A"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (desc.isNotEmpty) Text(desc),
                if (validity.isNotEmpty && validity != "N/A")
                  Text(
                    "Validity: $validity",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
            trailing: amount.isNotEmpty
                ? ElevatedButton(
                    onPressed: () {
                      amountController.text = amount;
                      selectedPlanAmount = amount;
                      selectedPlanName = desc.isNotEmpty ? desc : "Plan";
                      Navigator.pop(context);
                      _showInfoAlert("Plan Selected: ₹$amount");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorConst.primaryColor1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Choose",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                : null,
            onTap: amount.isNotEmpty
                ? () {
                    amountController.text = amount;
                    selectedPlanAmount = amount;
                    selectedPlanName = desc.isNotEmpty ? desc : "Plan";
                    Navigator.pop(context);
                    _showInfoAlert("Plan Selected: ₹$amount");
                  }
                : null,
          ),
        );
        items.add(const Divider());
      }
    } else {
      // fallback: show whole response
      items.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(const JsonEncoder.withIndent('  ').convert(data)),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: items.isNotEmpty
              ? ListView(children: items)
              : SingleChildScrollView(
                  child: Text(const JsonEncoder.withIndent('  ').convert(data)),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  // Helper method to get consistent input decoration for all fields
  InputDecoration _getStandardInputDecoration({
    String? hintText,
    String? labelText,
    String? errorText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool filled = true,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      errorText: errorText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorConst.primaryColor1, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      filled: filled,
      fillColor: fillColor ?? Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Full-screen loading overlay widget
  Widget _buildLoadingOverlay() {
    if (!isLoading) {
      return SizedBox.shrink();
    }

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo from AppBloc
              BlocBuilder<AppBloc, AppState>(
                buildWhen: (previous, current) => current is AppLoaded,
                builder: (context, state) {
                  String? logoPath;
                  if (state is AppLoaded && state.settings?.logo != null) {
                    logoPath =
                        "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                  }
                  return Container(
                    height: scrWidth * 0.12,
                    child: logoPath != null && logoPath.isNotEmpty
                        ? Image.network(
                            logoPath,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox.shrink();
                            },
                          )
                        : SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorConst.primaryColor1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Processing...",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Skeleton loader for operator dropdown
  Widget _buildOperatorDropdownSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDynamicButtons(List<ButtonModel> buttons) {
    // Filter out "Fetch Bill" buttons - they have a dedicated button section
    final filteredButtons = buttons.where((btn) {
      final label = btn.label.toLowerCase();
      // Exclude fetch bill buttons (they're handled separately)
      return !label.contains('fetch bill') && !label.contains('fetch-bill');
    }).toList();

    // Don't show Quick Actions section if no buttons after filtering
    if (filteredButtons.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorConst.primaryColor1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: filteredButtons.map((btn) {
            final label = btn.label;
            final type = btn.type;
            final function = btn.function;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // Get operator code from operatorList
                        String? operatorCode;
                        if (selectedOperator != null &&
                            operatorList.isNotEmpty) {
                          try {
                            final operator = operatorList.firstWhere((op) {
                              final id = (op['OperatorID'] is int)
                                  ? op['OperatorID'] as int
                                  : int.tryParse(op['OperatorID'].toString());
                              return id == selectedOperator;
                            }, orElse: () => null);
                            if (operator != null) {
                              operatorCode = operator['OperatorCode']
                                  ?.toString();
                            }
                          } catch (e) {
                            print('Error getting operator code: $e');
                          }
                        }

                        // Get mobile from form (validates all possible sources)
                        final mobile = _getMobileFromForm();

                        // Validate mobile for DTH Info and Heavy Refresh (required)
                        // Check both label and function URL
                        final requiresMobile =
                            label.toLowerCase().contains('dth info') ||
                            label.toLowerCase().contains('heavy refresh') ||
                            function.toLowerCase().contains(
                              'feature_type=dth_info',
                            ) ||
                            function.toLowerCase().contains(
                              'feature_type=heavy_refresh',
                            );

                        if (requiresMobile &&
                            (mobile.isEmpty || mobile.trim().isEmpty)) {
                          _showWarningAlert(
                            "Please enter mobile/consumer number first",
                          );
                          return;
                        }

                        String url = "${AssetsConst.apiBase}$function"
                            .replaceAll(
                              "{MOBILE}",
                              mobile.isNotEmpty
                                  ? mobile
                                  : mobileController.text,
                            )
                            .replaceAll(
                              "{OPERATOR}",
                              selectedOperator?.toString() ??
                                  widget.layout.operatorTypeId.toString(),
                            )
                            .replaceAll("{OPERATORCODE}", operatorCode ?? "");

                        if (type == "fetch" || type == "download") {
                          // Handle DTH-specific buttons
                          // Check both label and function URL for DTH info
                          final isDthInfo =
                              label.toLowerCase().contains('dth info') ||
                              function.toLowerCase().contains(
                                'feature_type=dth_info',
                              );
                          final isHeavyRefresh =
                              label.toLowerCase().contains('heavy refresh') ||
                              function.toLowerCase().contains(
                                'feature_type=heavy_refresh',
                              );

                          if (isDthInfo) {
                            print(
                              '🔍 [BUTTON_CLICK] DTH Info button detected - Label: "$label", Function: "$function"',
                            );
                            fetchDthInfo(url);
                          } else if (isHeavyRefresh) {
                            print(
                              '🔍 [BUTTON_CLICK] Heavy Refresh button detected - Label: "$label", Function: "$function"',
                            );
                            performDthHeavyRefresh(url);
                          } else {
                            print(
                              '🔍 [BUTTON_CLICK] Plans/Offers button detected - Label: "$label", Function: "$function"',
                            );
                            fetchPlans(url, label);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorConst.primaryColor1,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = _getCurrentLayout(); // Use operator form config if available
    return PopScope(
      onPopInvoked: (didPop) {
        // Refresh home screen data when navigating back from recharge page
        if (didPop) {
          try {
            // Refresh only balance and stats (preserves profile picture)
            // Use try-catch for each bloc access to handle cases where they might not be available
            try {
              final userBloc = context.read<UserBloc>();
              userBloc.add(const RefreshBalanceOnlyEvent());
            } catch (e) {
              print('⚠️ [RECHARGE_PAGE] UserBloc not available: $e');
            }

            try {
              final dashboardBloc = context.read<DashboardBloc>();
              dashboardBloc.add(FetchDashboardStatistics(period: 'month'));
            } catch (e) {
              print('⚠️ [RECHARGE_PAGE] DashboardBloc not available: $e');
            }

            print(
              '🔄 [RECHARGE_PAGE] Attempted to refresh balance and stats on back navigation',
            );
          } catch (e) {
            print('⚠️ [RECHARGE_PAGE] Could not refresh home data: $e');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
                            // Refresh home screen before navigating back
                            try {
                              // Refresh only balance and stats before navigating back (preserves profile picture)
                              // Use try-catch for each bloc access to handle cases where they might not be available
                              try {
                                final userBloc = context.read<UserBloc>();
                                userBloc.add(const RefreshBalanceOnlyEvent());
                              } catch (e) {
                                print(
                                  '⚠️ [RECHARGE_PAGE] UserBloc not available: $e',
                                );
                              }

                              try {
                                final dashboardBloc = context
                                    .read<DashboardBloc>();
                                dashboardBloc.add(
                                  FetchDashboardStatistics(period: 'month'),
                                );
                              } catch (e) {
                                print(
                                  '⚠️ [RECHARGE_PAGE] DashboardBloc not available: $e',
                                );
                              }

                              print(
                                '🔄 [RECHARGE_PAGE] Attempted to refresh balance and stats before back navigation',
                              );
                            } catch (e) {
                              print(
                                '⚠️ [RECHARGE_PAGE] Could not refresh home data: $e',
                              );
                            }
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
                    // Right: Wallet balance
                    BlocBuilder<UserBloc, UserState>(
                      buildWhen: (previous, current) => current is UserLoaded,
                      builder: (context, state) {
                        String balance = '0.00';
                        if (state is UserLoaded) {
                          balance = state.user.balance ?? '0.00';
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Wallet',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                                fontSize: scrWidth * 0.028,
                              ),
                            ),
                            Text(
                              '₹ $balance',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorConst.primaryColor1,
                                fontSize: scrWidth * 0.032,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Service Name Display Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorConst.primaryColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorConst.primaryColor1.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.layout.operatorTypeName,
                          style: TextStyle(
                            fontSize: scrWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: colorConst.primaryColor1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 100,
                      left: 12,
                      right: 12,
                    ),
                    child: Builder(
                      builder: (context) {
                        final layout = _getCurrentLayout();
                        final billFetchMode = _getBillFetchMode();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer name display (when bill is fetched)
                            if (billInfo != null &&
                                billInfo!.name.isNotEmpty &&
                                isBillFetched)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: colorConst.primaryColor1,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        billInfo!.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: scrWidth * 0.035,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Operator Check Field (Show FIRST if enabled)
                            if (hasOperatorCheck &&
                                operatorCheckFieldConfig != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    operatorCheckFieldConfig!.fieldLabel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller:
                                        extraFieldControllers[operatorCheckFieldConfig!
                                            .fieldName],
                                    keyboardType:
                                        operatorCheckFieldConfig!.fieldType ==
                                            'tel'
                                        ? TextInputType.phone
                                        : TextInputType.text,
                                    decoration: _getStandardInputDecoration(
                                      hintText:
                                          operatorCheckFieldConfig!.placeholder,
                                      suffixIcon: isFetchingOperator
                                          ? const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.phone,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade900,
                                    ),
                                    onChanged: (value) {
                                      print(
                                        '🔘 [OPERATOR_CHECK_FIELD_CHANGED] Value: $value, length: ${value.length}',
                                      );
                                      print(
                                        '   📋 Field name: ${operatorCheckFieldConfig!.fieldName}',
                                      );
                                      // Auto-detect operator when field value changes
                                      if (operatorCheckFieldConfig!.fieldName ==
                                              'mobile' &&
                                          value.length == 10) {
                                        print(
                                          '   ✅ Mobile number complete (10 digits), calling fetchAutoOperatorFromCheckField...',
                                        );
                                        fetchAutoOperatorFromCheckField(value);
                                      } else {
                                        print(
                                          '   ⏸️ Not triggering auto-fetch (fieldName: ${operatorCheckFieldConfig!.fieldName}, length: ${value.length})',
                                        );
                                      }
                                    },
                                  ),
                                  if (operatorCheckFieldConfig!.helpText !=
                                          null &&
                                      operatorCheckFieldConfig!
                                          .helpText!
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        operatorCheckFieldConfig!.helpText!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                ],
                              ),

                            // Mobile number field (only show if operator check NOT enabled)
                            if (!hasOperatorCheck &&
                                layout.defaultNumber?.enabled == true)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    layout.defaultNumber?.name ??
                                        "Mobile Number",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: mobileController,
                                    decoration: _getStandardInputDecoration(
                                      hintText:
                                          layout.defaultNumber?.hint ??
                                          "Enter mobile number",
                                      suffixIcon: isFetchingOperator
                                          ? const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.phone,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),

                            // Operator dropdown (always show when enabled, whether operator check is enabled or not)
                            if (layout.operatorDropdown?.enabled == true)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Operator",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Show skeleton loader when fetching operator
                                  if (isFetchingOperator)
                                    _buildOperatorDropdownSkeleton()
                                  else
                                    DropdownButtonFormField<int>(
                                      dropdownColor: Colors.white,
                                      isExpanded: true,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade900,
                                      ),
                                      decoration: _getStandardInputDecoration(
                                        hintText: "Choose operator",
                                      ),
                                      value: selectedOperator,
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                            return operatorList.map<Widget>((
                                              op,
                                            ) {
                                              final id =
                                                  (op['OperatorID'] is int)
                                                  ? op['OperatorID'] as int
                                                  : int.tryParse(
                                                          op['OperatorID']
                                                              .toString(),
                                                        ) ??
                                                        0;
                                              final imageUrl =
                                                  _getOperatorImageUrlById(id);
                                              final operatorName =
                                                  op['OperatorName'] ??
                                                  op['OperatorName_DB'] ??
                                                  '';

                                              return Row(
                                                children: [
                                                  if (imageUrl != null)
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                      margin: EdgeInsets.only(
                                                        right: 12,
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: imageUrl,
                                                        fit: BoxFit.contain,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: Icon(
                                                                Icons.sim_card,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: Icon(
                                                                Icons.sim_card,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            ),
                                                      ),
                                                    )
                                                  else
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                      margin: EdgeInsets.only(
                                                        right: 12,
                                                      ),
                                                      child: Icon(
                                                        Icons.sim_card,
                                                        size: 20,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: Text(
                                                      operatorName,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList();
                                          },
                                      items: operatorList
                                          .map<DropdownMenuItem<int>>((op) {
                                            final id = (op['OperatorID'] is int)
                                                ? op['OperatorID'] as int
                                                : int.tryParse(
                                                        op['OperatorID']
                                                            .toString(),
                                                      ) ??
                                                      0;
                                            final imageUrl =
                                                _getOperatorImageUrlById(id);
                                            final operatorName =
                                                op['OperatorName'] ??
                                                op['OperatorName_DB'] ??
                                                '';

                                            return DropdownMenuItem(
                                              value: id,
                                              child: Row(
                                                children: [
                                                  if (imageUrl != null)
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                      margin: EdgeInsets.only(
                                                        right: 12,
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: imageUrl,
                                                        fit: BoxFit.contain,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: Icon(
                                                                Icons.sim_card,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: Icon(
                                                                Icons.sim_card,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            ),
                                                      ),
                                                    )
                                                  else
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                      margin: EdgeInsets.only(
                                                        right: 12,
                                                      ),
                                                      child: Icon(
                                                        Icons.sim_card,
                                                        size: 20,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: Text(
                                                      operatorName,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (val) {
                                        print(
                                          '🔘 [OPERATOR_DROPDOWN_CHANGED] Selected operator: $val',
                                        );
                                        setState(() {
                                          selectedOperator = val;
                                          isOperatorFetched = val != null;
                                          // Reset bill fetched state when operator changes
                                          if (val != null) {
                                            isBillFetched = false;
                                            billInfo = null;
                                            print(
                                              '🔄 [OPERATOR_CHANGED] Reset isBillFetched=false, billInfo=null',
                                            );
                                          }
                                        });
                                        print(
                                          '   ✅ Set selectedOperator = $val, isOperatorFetched = $isOperatorFetched',
                                        );

                                        // Fetch operator form config when operator is selected
                                        if (val != null) {
                                          print(
                                            '   🔄 Calling fetchOperatorFormConfig($val)...',
                                          );
                                          fetchOperatorFormConfig(val);
                                        } else {
                                          print(
                                            '   ⚠️ val is null, clearing operatorFormConfig',
                                          );
                                          setState(() {
                                            operatorFormConfig = null;
                                          });
                                        }
                                      },
                                    ),
                                  const SizedBox(height: 20),
                                ],
                              ),

                            // Dynamic amount field (only show if operator selected AND not in API fields)
                            // Check if amount is in fields array - if yes, don't show hardcoded amount
                            Builder(
                              builder: (context) {
                                // Only show hardcoded amount if operator is selected
                                if (operatorFormConfig == null) {
                                  return SizedBox.shrink();
                                }

                                final currentFields = _getCurrentFields();
                                final hasAmountInFields = currentFields.any(
                                  (field) =>
                                      (field['name'] == 'amount' ||
                                      field['name'] == 'Amount'),
                                );

                                // Show hardcoded amount field if:
                                // 1. Amount is not in API fields
                                // 2. Amount field is enabled
                                // Note: Don't hide based on bill_fetch_mode - editability is handled by _isAmountEditable()
                                if (!hasAmountInFields &&
                                    _getCurrentLayout().amount?.enabled ==
                                        true) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Amount",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: amountController,
                                        enabled: () {
                                          final editable = _isAmountEditable();
                                          print(
                                            '🔘 [HARDCODED_AMOUNT_FIELD] enabled check: $editable',
                                          );
                                          return editable;
                                        }(),
                                        readOnly:
                                            !_isAmountEditable(), // Ensure non-editable when _isAmountEditable() returns false
                                        decoration: _getStandardInputDecoration(
                                          hintText: "Enter amount",
                                          prefixIcon: Icon(
                                            Icons.currency_rupee,
                                            color: Colors.grey.shade400,
                                            size: 20,
                                          ),
                                          fillColor: !_isAmountEditable()
                                              ? Colors.grey.shade100
                                              : Colors.grey.shade50,
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),

                            // Bill information display
                            if (billInfo != null && isBillFetched)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.receipt,
                                          color: colorConst.primaryColor1,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Bill Information",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: colorConst.primaryColor1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (billInfo!.name.isNotEmpty)
                                      _buildInfoRow("Customer", billInfo!.name),
                                    if (billInfo!.billNumber.isNotEmpty)
                                      _buildInfoRow(
                                        "Bill Number",
                                        billInfo!.billNumber,
                                      ),
                                    if (billInfo!.billDate.isNotEmpty)
                                      _buildInfoRow(
                                        "Bill Date",
                                        billInfo!.billDate,
                                      ),
                                    if (billInfo!.dueDate.isNotEmpty)
                                      _buildInfoRow(
                                        "Due Date",
                                        billInfo!.dueDate,
                                      ),
                                  ],
                                ),
                              ),

                            // DTH Info display
                            if (dthInfo != null && isDthInfoFetched)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.tv,
                                          color: colorConst.primaryColor1,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "DTH Info - ${dthInfo!.operator}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: colorConst.primaryColor1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (dthInfo!.records.isNotEmpty)
                                      ...dthInfo!.records
                                          .map(
                                            (record) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildInfoRow(
                                                  "Customer",
                                                  record.customerName.isNotEmpty
                                                      ? record.customerName
                                                      : "N/A",
                                                ),
                                                _buildInfoRow(
                                                  "Plan",
                                                  record.planName.isNotEmpty
                                                      ? record.planName
                                                      : "N/A",
                                                ),
                                                _buildInfoRow(
                                                  "Balance",
                                                  record.balance.isNotEmpty
                                                      ? "₹${record.balance}"
                                                      : "N/A",
                                                ),
                                                _buildInfoRow(
                                                  "Monthly Recharge",
                                                  record
                                                          .monthlyRecharge
                                                          .isNotEmpty
                                                      ? "₹${record.monthlyRecharge}"
                                                      : "N/A",
                                                ),
                                                _buildInfoRow(
                                                  "Next Recharge",
                                                  record
                                                          .nextRechargeDate
                                                          .isNotEmpty
                                                      ? record.nextRechargeDate
                                                      : "N/A",
                                                ),
                                                _buildInfoRow(
                                                  "Status",
                                                  record.status.isNotEmpty
                                                      ? record.status
                                                      : "N/A",
                                                ),
                                                if (record
                                                    .lastRechargeAmount
                                                    .isNotEmpty)
                                                  _buildInfoRow(
                                                    "Last Recharge",
                                                    "₹${record.lastRechargeAmount}",
                                                  ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          )
                                          .toList()
                                    else
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          "No DTH information available",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Extra dynamic fields (exclude amount if shown separately, and operator check field)
                            // Show fields from operator form config when operator is selected
                            Builder(
                              builder: (context) {
                                print('🎨 [BUILD_DYNAMIC_FIELDS] START');
                                print(
                                  '   📊 operatorFormConfig: ${operatorFormConfig != null ? "SET" : "NULL"}',
                                );
                                print(
                                  '   📊 isOperatorFetched: $isOperatorFetched',
                                );
                                print(
                                  '   📊 selectedOperator: $selectedOperator',
                                );
                                print(
                                  '   📊 hasOperatorCheck: $hasOperatorCheck',
                                );
                                print(
                                  '   📊 operatorCheckFieldConfig?.fieldName: ${operatorCheckFieldConfig?.fieldName}',
                                );

                                final currentFields = _getCurrentFields();
                                print(
                                  '   📋 currentFields count: ${currentFields.length}',
                                );

                                if (currentFields.isEmpty) {
                                  print(
                                    '   ⚠️ No fields available, returning empty widget',
                                  );
                                  return SizedBox.shrink();
                                }

                                // Determine operator check field name
                                // According to backend docs: Skip mobile field if operator check enabled AND field names match
                                final operatorCheckFieldName =
                                    hasOperatorCheck &&
                                        operatorCheckFieldConfig != null
                                    ? operatorCheckFieldConfig!.fieldName
                                    : null;

                                print(
                                  '   🔍 Skip check: hasOperatorCheck=$hasOperatorCheck',
                                );
                                print(
                                  '   🔍 operatorCheckFieldConfig: ${operatorCheckFieldConfig != null}',
                                );
                                print(
                                  '   🔍 operatorCheckFieldName: $operatorCheckFieldName',
                                );
                                print(
                                  '   🔍 operatorFormConfig: ${operatorFormConfig != null ? "SET" : "NULL"}',
                                );

                                final filteredFields = currentFields.where((
                                  field,
                                ) {
                                  final name = field['name'];
                                  final nameStr = name?.toString() ?? '';

                                  print(
                                    '   🔍 Checking field: name="$nameStr" (type: ${name.runtimeType})',
                                  );

                                  // Skip mobile field if operator check is enabled AND field name matches
                                  // This prevents duplicate mobile field (one from operator check, one from form config)
                                  // Backend docs: Skip mobile field if operator check enabled (to prevent duplicate with initial field)
                                  final shouldSkipMobileField =
                                      hasOperatorCheck &&
                                      operatorCheckFieldName != null &&
                                      nameStr ==
                                          operatorCheckFieldName; // Skip if name matches operator check field name

                                  print('   🔍 Field "$nameStr" analysis:');
                                  print(
                                    '      - hasOperatorCheck: $hasOperatorCheck',
                                  );
                                  print(
                                    '      - operatorCheckFieldName: $operatorCheckFieldName',
                                  );
                                  print(
                                    '      - nameStr == operatorCheckFieldName: ${nameStr == operatorCheckFieldName}',
                                  );
                                  print(
                                    '      - shouldSkipMobileField: $shouldSkipMobileField',
                                  );

                                  // Check flow control - show_after_operator_fetch
                                  if (field['show_after_operator_fetch'] ==
                                          true &&
                                      !isOperatorFetched) {
                                    print(
                                      '   ⏭️ Skipping field "$nameStr" - show_after_operator_fetch=true but operator not fetched',
                                    );
                                    return false;
                                  }

                                  // Check flow control - show_after_bill_fetch
                                  if (field['show_after_bill_fetch'] == true &&
                                      !isBillFetched) {
                                    print(
                                      '   ⏭️ Skipping field "$nameStr" - show_after_bill_fetch=true but bill not fetched',
                                    );
                                    return false;
                                  }

                                  // Only skip mobile field (when operator check enabled), NOT amount
                                  // Amount field from operatorFormConfig should always display
                                  // The hardcoded amount field will auto-hide when amount is in API fields
                                  final shouldShow = !shouldSkipMobileField;
                                  if (shouldShow) {
                                    print('   ✅ INCLUDING field: "$nameStr"');
                                  } else {
                                    print(
                                      '   ❌ EXCLUDING field: "$nameStr" (shouldSkipMobileField: $shouldSkipMobileField)',
                                    );
                                  }
                                  return shouldShow;
                                });

                                final sortedFields = filteredFields.toList();
                                print(
                                  '   📋 After filtering: ${sortedFields.length} fields',
                                );

                                // Sort by display_order
                                sortedFields.sort((a, b) {
                                  int orderA = a['display_order'] ?? 999;
                                  int orderB = b['display_order'] ?? 999;
                                  return orderA.compareTo(orderB);
                                });

                                print(
                                  '   ✅ Sorted fields, final count: ${sortedFields.length}',
                                );

                                // Reset skip flag after rendering (per web logic)
                                // Note: This happens on each build, which is fine - the flag is recalculated above

                                print('🎨 [BUILD_DYNAMIC_FIELDS] END');

                                return Column(
                                  children: sortedFields.map((field) {
                                    final name = field['name'];
                                    final label =
                                        field['label'] ?? field['hint'] ?? name;
                                    final hint =
                                        field['hint'] ??
                                        field['placeholder'] ??
                                        label;
                                    final placeholder =
                                        field['placeholder'] ?? hint;
                                    final fieldType =
                                        field['type']?.toString() ?? 'text';
                                    final isRequired =
                                        field['required'] == true;
                                    final nameStr = name?.toString() ?? '';
                                    final remark =
                                        field['remark']?.toString() ?? '';
                                    final options =
                                        field['options'] as List<dynamic>?;
                                    final showAfterBillFetch =
                                        field['show_after_bill_fetch'] == true;
                                    final isEditableAfterFetch =
                                        field['is_editable_after_fetch'] ??
                                        true;

                                    // Check if this is an amount field and should be non-editable
                                    final isAmountField =
                                        nameStr.toLowerCase() == 'amount';
                                    final shouldBeEditable = isAmountField
                                        ? () {
                                            final editable =
                                                _isAmountEditable();
                                            print(
                                              '🔘 [DYNAMIC_AMOUNT_FIELD] Field "$nameStr" editability: $editable',
                                            );
                                            return editable;
                                          }()
                                        : (showAfterBillFetch && isBillFetched
                                              ? isEditableAfterFetch
                                              : true);

                                    if (isAmountField) {
                                      print(
                                        '   📊 Amount field "$nameStr" details:',
                                      );
                                      print(
                                        '      - isBillFetched: $isBillFetched',
                                      );
                                      print(
                                        '      - billFetchMode: ${_getBillFetchMode()}',
                                      );
                                      print(
                                        '      - shouldBeEditable: $shouldBeEditable',
                                      );
                                    }

                                    // Get validation error if any
                                    String? validationError;
                                    if (extraFieldControllers.containsKey(
                                      name,
                                    )) {
                                      final value =
                                          extraFieldControllers[name]!.text;
                                      final result = _validateField(
                                        field,
                                        value,
                                      );
                                      if (!result.isValid && value.isNotEmpty) {
                                        validationError = result.errorMessage;
                                      }
                                    }

                                    Widget fieldWidget;

                                    // Render based on field type
                                    switch (fieldType) {
                                      case 'select':
                                        // Dropdown/Select field
                                        final selectedValue =
                                            extraFieldControllers.containsKey(
                                              name,
                                            )
                                            ? extraFieldControllers[name]!.text
                                            : null;
                                        fieldWidget =
                                            DropdownButtonFormField<String>(
                                              value:
                                                  selectedValue?.isNotEmpty ==
                                                      true
                                                  ? selectedValue
                                                  : null,
                                              decoration:
                                                  _getStandardInputDecoration(
                                                    labelText: label,
                                                    hintText: placeholder,
                                                    errorText: validationError,
                                                    helperText:
                                                        remark.isNotEmpty
                                                        ? remark
                                                        : null,
                                                    fillColor: !shouldBeEditable
                                                        ? Colors.grey.shade100
                                                        : Colors.grey.shade50,
                                                  ),
                                              items: (options ?? []).map((
                                                option,
                                              ) {
                                                final value =
                                                    option['value']
                                                        ?.toString() ??
                                                    '';
                                                final optionLabel =
                                                    option['label']
                                                        ?.toString() ??
                                                    value;
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(optionLabel),
                                                );
                                              }).toList(),
                                              onChanged: shouldBeEditable
                                                  ? (value) {
                                                      if (value != null &&
                                                          extraFieldControllers
                                                              .containsKey(
                                                                name,
                                                              )) {
                                                        extraFieldControllers[name]!
                                                                .text =
                                                            value;
                                                        setState(() {});
                                                      }
                                                    }
                                                  : null,
                                            );
                                        break;

                                      case 'textarea':
                                        // Multi-line text field
                                        fieldWidget = TextField(
                                          controller:
                                              extraFieldControllers[name],
                                          enabled: shouldBeEditable,
                                          readOnly:
                                              !shouldBeEditable, // Ensure non-editable when shouldBeEditable is false
                                          maxLines: 4,
                                          decoration:
                                              _getStandardInputDecoration(
                                                labelText: label,
                                                hintText: placeholder,
                                                errorText: validationError,
                                                helperText: remark.isNotEmpty
                                                    ? remark
                                                    : null,
                                                fillColor: !shouldBeEditable
                                                    ? Colors.grey.shade100
                                                    : Colors.grey.shade50,
                                              ),
                                        );
                                        break;

                                      case 'date':
                                        // Date picker field
                                        fieldWidget = TextField(
                                          controller:
                                              extraFieldControllers[name],
                                          enabled: shouldBeEditable,
                                          readOnly: true,
                                          decoration:
                                              _getStandardInputDecoration(
                                                labelText: label,
                                                hintText: placeholder,
                                                errorText: validationError,
                                                helperText: remark.isNotEmpty
                                                    ? remark
                                                    : null,
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.grey.shade400,
                                                  size: 20,
                                                ),
                                                fillColor: !shouldBeEditable
                                                    ? Colors.grey.shade100
                                                    : Colors.grey.shade50,
                                              ),
                                          onTap: shouldBeEditable
                                              ? () async {
                                                  final date = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2100),
                                                    builder: (context, child) {
                                                      return Theme(
                                                        data: Theme.of(context).copyWith(
                                                          dialogBackgroundColor:
                                                              Colors.white,
                                                          colorScheme:
                                                              ColorScheme.light(
                                                                primary: colorConst
                                                                    .primaryColor1,
                                                                onPrimary:
                                                                    Colors
                                                                        .white,
                                                                onSurface:
                                                                    Colors
                                                                        .black,
                                                                surface: Colors
                                                                    .white,
                                                              ),
                                                          textButtonTheme:
                                                              TextButtonThemeData(
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      colorConst
                                                                          .primaryColor1,
                                                                ),
                                                              ),
                                                        ),
                                                        child: child!,
                                                      );
                                                    },
                                                  );
                                                  if (date != null &&
                                                      extraFieldControllers
                                                          .containsKey(name)) {
                                                    extraFieldControllers[name]!
                                                            .text =
                                                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                                    setState(() {});
                                                  }
                                                }
                                              : null,
                                        );
                                        break;

                                      case 'datetime-local':
                                        // Date and time picker field
                                        fieldWidget = TextField(
                                          controller:
                                              extraFieldControllers[name],
                                          enabled: shouldBeEditable,
                                          readOnly: true,
                                          decoration:
                                              _getStandardInputDecoration(
                                                labelText: label,
                                                hintText: placeholder,
                                                errorText: validationError,
                                                helperText: remark.isNotEmpty
                                                    ? remark
                                                    : null,
                                                suffixIcon: Icon(
                                                  Icons.access_time,
                                                  color: Colors.grey.shade400,
                                                  size: 20,
                                                ),
                                                fillColor: !shouldBeEditable
                                                    ? Colors.grey.shade100
                                                    : Colors.grey.shade50,
                                              ),
                                          onTap: shouldBeEditable
                                              ? () async {
                                                  final date = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2100),
                                                    builder: (context, child) {
                                                      return Theme(
                                                        data: Theme.of(context).copyWith(
                                                          dialogBackgroundColor:
                                                              Colors.white,
                                                          colorScheme:
                                                              ColorScheme.light(
                                                                primary: colorConst
                                                                    .primaryColor1,
                                                                onPrimary:
                                                                    Colors
                                                                        .white,
                                                                onSurface:
                                                                    Colors
                                                                        .black,
                                                                surface: Colors
                                                                    .white,
                                                              ),
                                                          textButtonTheme:
                                                              TextButtonThemeData(
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      colorConst
                                                                          .primaryColor1,
                                                                ),
                                                              ),
                                                        ),
                                                        child: child!,
                                                      );
                                                    },
                                                  );
                                                  if (date != null) {
                                                    final time =
                                                        await showTimePicker(
                                                          context: context,
                                                          initialTime:
                                                              TimeOfDay.now(),
                                                        );
                                                    if (time != null &&
                                                        extraFieldControllers
                                                            .containsKey(
                                                              name,
                                                            )) {
                                                      final dateTime = DateTime(
                                                        date.year,
                                                        date.month,
                                                        date.day,
                                                        time.hour,
                                                        time.minute,
                                                      );
                                                      extraFieldControllers[name]!
                                                              .text =
                                                          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                                      setState(() {});
                                                    }
                                                  }
                                                }
                                              : null,
                                        );
                                        break;

                                      case 'email':
                                        // Email field
                                        fieldWidget = TextField(
                                          controller:
                                              extraFieldControllers[name],
                                          enabled: shouldBeEditable,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration:
                                              _getStandardInputDecoration(
                                                labelText: label,
                                                hintText: placeholder,
                                                errorText: validationError,
                                                helperText: remark.isNotEmpty
                                                    ? remark
                                                    : null,
                                                fillColor: !shouldBeEditable
                                                    ? Colors.grey.shade100
                                                    : Colors.grey.shade50,
                                              ),
                                        );
                                        break;

                                      case 'number':
                                        // Number field (including amount field)
                                        fieldWidget = TextField(
                                          controller:
                                              extraFieldControllers[name],
                                          enabled: shouldBeEditable,
                                          readOnly:
                                              !shouldBeEditable, // Ensure non-editable when shouldBeEditable is false
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration:
                                              _getStandardInputDecoration(
                                                labelText: label,
                                                hintText: placeholder,
                                                errorText: validationError,
                                                helperText: remark.isNotEmpty
                                                    ? remark
                                                    : null,
                                                fillColor: !shouldBeEditable
                                                    ? Colors.grey.shade100
                                                    : Colors.grey.shade50,
                                              ),
                                        );
                                        break;

                                      case 'tel':
                                        // Phone/Mobile field
                                        fieldWidget = TextField(
                                          controller:
                                              extraFieldControllers[name],
                                          enabled: shouldBeEditable,
                                          readOnly:
                                              !shouldBeEditable, // Ensure non-editable when shouldBeEditable is false
                                          keyboardType: TextInputType.phone,
                                          decoration:
                                              _getStandardInputDecoration(
                                                labelText: label,
                                                hintText: placeholder,
                                                errorText: validationError,
                                                helperText: remark.isNotEmpty
                                                    ? remark
                                                    : null,
                                                fillColor: !shouldBeEditable
                                                    ? Colors.grey.shade100
                                                    : Colors.grey.shade50,
                                              ),
                                        );
                                        break;

                                      default:
                                        // Text field (default)
                                        fieldWidget = TextField(
                                          controller:
                                              extraFieldControllers[name],
                                          enabled: shouldBeEditable,
                                          keyboardType: TextInputType.text,
                                          decoration:
                                              _getStandardInputDecoration(
                                                labelText: label,
                                                hintText: placeholder,
                                                errorText: validationError,
                                                helperText: remark.isNotEmpty
                                                    ? remark
                                                    : null,
                                                fillColor: !shouldBeEditable
                                                    ? Colors.grey.shade100
                                                    : Colors.grey.shade50,
                                              ),
                                        );
                                        break;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: fieldWidget,
                                    );
                                  }).toList(),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Dynamic Buttons (plans/offers) - Only show when operator is selected
                            // Buttons come from operatorFormConfig when available (varies per operator)
                            if (operatorFormConfig != null &&
                                layout.buttons != null &&
                                layout.buttons!.isNotEmpty)
                              buildDynamicButtons(layout.buttons!),

                            // Categorized Plans Display (display_format: "categorized")
                            if (showPlansOffers &&
                                isCategorizedPlans &&
                                categorizedPlans.isNotEmpty &&
                                planCategories.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentOffersLabel ?? "Select Plan",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorConst.primaryColor1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: DefaultTabController(
                                        length: planCategories.length,
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        12,
                                                      ),
                                                      topRight: Radius.circular(
                                                        12,
                                                      ),
                                                    ),
                                              ),
                                              child: TabBar(
                                                isScrollable: true,
                                                indicatorColor:
                                                    colorConst.primaryColor1,
                                                labelColor:
                                                    colorConst.primaryColor1,
                                                unselectedLabelColor:
                                                    Colors.grey,
                                                labelStyle: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                tabs: planCategories
                                                    .map(
                                                      (category) =>
                                                          Tab(text: category),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 300,
                                              child: TabBarView(
                                                children: planCategories.map((
                                                  category,
                                                ) {
                                                  final plans =
                                                      categorizedPlans[category] ??
                                                      [];
                                                  return ListView.builder(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    itemCount: plans.length,
                                                    itemBuilder: (context, index) {
                                                      final plan =
                                                          plans[index]
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >;

                                                      // Handle DTH plans with amount_options
                                                      if (plan['amount_options'] !=
                                                          null) {
                                                        final planName =
                                                            plan['plan_name']
                                                                ?.toString() ??
                                                            '';
                                                        final description =
                                                            plan['description']
                                                                ?.toString() ??
                                                            '';
                                                        final amountOptions =
                                                            plan['amount_options']
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >;

                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical: 8,
                                                                  ),
                                                              child: Text(
                                                                planName,
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            if (description
                                                                .isNotEmpty)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      bottom: 8,
                                                                    ),
                                                                child: Text(
                                                                  description,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey[600],
                                                                  ),
                                                                ),
                                                              ),
                                                            ...amountOptions.entries.map((
                                                              entry,
                                                            ) {
                                                              final duration =
                                                                  entry.key;
                                                              final amount = entry
                                                                  .value
                                                                  .toString();
                                                              final isSelected =
                                                                  selectedPlanAmount ==
                                                                  amount;

                                                              return Container(
                                                                margin:
                                                                    const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      isSelected
                                                                      ? colorConst
                                                                            .primaryColor1
                                                                            .withOpacity(
                                                                              0.1,
                                                                            )
                                                                      : Colors
                                                                            .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  border: Border.all(
                                                                    color:
                                                                        isSelected
                                                                        ? colorConst
                                                                              .primaryColor1
                                                                        : Colors
                                                                              .grey
                                                                              .shade200,
                                                                    width:
                                                                        isSelected
                                                                        ? 2
                                                                        : 1,
                                                                  ),
                                                                ),
                                                                child: ListTile(
                                                                  title: Text(
                                                                    "₹$amount - $duration",
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          isSelected
                                                                          ? colorConst.primaryColor1
                                                                          : Colors.black87,
                                                                    ),
                                                                  ),
                                                                  subtitle: Text(
                                                                    planName,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey[600],
                                                                    ),
                                                                  ),
                                                                  trailing: Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          6,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: colorConst
                                                                          .primaryColor1,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            20,
                                                                          ),
                                                                    ),
                                                                    child: Text(
                                                                      "₹$amount",
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    _prefillAmount(
                                                                      amount,
                                                                    );
                                                                    setState(() {
                                                                      selectedPlanName =
                                                                          "$planName ($duration)";
                                                                    });
                                                                    _showInfoAlert(
                                                                      "Selected: $planName ($duration) - ₹$amount",
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            }),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                          ],
                                                        );
                                                      }

                                                      // Regular plan format
                                                      final amount =
                                                          plan['amount']
                                                              ?.toString() ??
                                                          plan['rs']
                                                              ?.toString() ??
                                                          '';
                                                      final desc =
                                                          plan['desc']
                                                              ?.toString() ??
                                                          plan['description']
                                                              ?.toString() ??
                                                          '';
                                                      final validity =
                                                          plan['validity']
                                                              ?.toString() ??
                                                          '';
                                                      final isSelected =
                                                          selectedPlanAmount ==
                                                          amount;

                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? colorConst
                                                                    .primaryColor1
                                                                    .withOpacity(
                                                                      0.1,
                                                                    )
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: isSelected
                                                                ? colorConst
                                                                      .primaryColor1
                                                                : Colors
                                                                      .grey
                                                                      .shade200,
                                                            width: isSelected
                                                                ? 2
                                                                : 1,
                                                          ),
                                                        ),
                                                        child: ListTile(
                                                          title: Text(
                                                            amount.isNotEmpty
                                                                ? "₹$amount"
                                                                : "N/A",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isSelected
                                                                  ? colorConst
                                                                        .primaryColor1
                                                                  : Colors
                                                                        .black87,
                                                            ),
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (desc
                                                                  .isNotEmpty)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        top: 4,
                                                                      ),
                                                                  child: Text(
                                                                    desc,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey[600],
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (validity
                                                                      .isNotEmpty &&
                                                                  validity !=
                                                                      "N/A")
                                                                Text(
                                                                  "Validity: $validity",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey[600],
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          trailing:
                                                              amount.isNotEmpty
                                                              ? Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            6,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: colorConst
                                                                        .primaryColor1,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          20,
                                                                        ),
                                                                  ),
                                                                  child: Text(
                                                                    "₹$amount",
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  ),
                                                                )
                                                              : null,
                                                          onTap:
                                                              amount.isNotEmpty
                                                              ? () {
                                                                  _prefillAmount(
                                                                    amount,
                                                                  );
                                                                  setState(() {
                                                                    selectedPlanName =
                                                                        desc.isNotEmpty
                                                                        ? desc
                                                                        : "Plan";
                                                                  });
                                                                  _showInfoAlert(
                                                                    "Selected: ₹$amount",
                                                                  );
                                                                }
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Plans Selection (Tabbed UI for DTH Plans)
                            if (showPlansOffers &&
                                dthPlans != null &&
                                isDthPlansFetched)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Select Plan",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorConst.primaryColor1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: DefaultTabController(
                                        length: dthPlans!.records.length,
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        12,
                                                      ),
                                                      topRight: Radius.circular(
                                                        12,
                                                      ),
                                                    ),
                                              ),
                                              child: TabBar(
                                                isScrollable: true,
                                                indicatorColor:
                                                    colorConst.primaryColor1,
                                                labelColor:
                                                    colorConst.primaryColor1,
                                                unselectedLabelColor:
                                                    Colors.grey,
                                                labelStyle: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                tabs: dthPlans!.records.keys
                                                    .map(
                                                      (category) =>
                                                          Tab(text: category),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 300,
                                              child: TabBarView(
                                                children: dthPlans!.records.entries.map((
                                                  entry,
                                                ) {
                                                  return ListView.builder(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    itemCount:
                                                        entry.value.length,
                                                    itemBuilder: (context, index) {
                                                      final plan =
                                                          entry.value[index];
                                                      final amount = plan
                                                          .getAmount();
                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              selectedPlanAmount ==
                                                                  amount
                                                              ? colorConst
                                                                    .primaryColor1
                                                                    .withOpacity(
                                                                      0.1,
                                                                    )
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                selectedPlanAmount ==
                                                                    amount
                                                                ? colorConst
                                                                      .primaryColor1
                                                                : Colors
                                                                      .grey
                                                                      .shade200,
                                                            width:
                                                                selectedPlanAmount ==
                                                                    amount
                                                                ? 2
                                                                : 1,
                                                          ),
                                                        ),
                                                        child: ListTile(
                                                          title: Text(
                                                            plan.planName,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  selectedPlanAmount ==
                                                                      amount
                                                                  ? colorConst
                                                                        .primaryColor1
                                                                  : Colors
                                                                        .black87,
                                                            ),
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                plan.desc,
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                              ),
                                                              if (plan.validity !=
                                                                      null &&
                                                                  plan
                                                                      .validity!
                                                                      .isNotEmpty)
                                                                Text(
                                                                  "Validity: ${plan.validity}",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey[600],
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          trailing: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: colorConst
                                                                  .primaryColor1,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              "₹$amount",
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            _prefillAmount(
                                                              amount,
                                                            );
                                                            setState(() {
                                                              selectedPlanName =
                                                                  plan.planName;
                                                            });
                                                            _showInfoAlert(
                                                              "Selected: ${plan.planName} - ₹$amount",
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Offers/Plans Display (List format - flat display_format)
                            if (showPlansOffers &&
                                isOffersFetched &&
                                offers.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentOffersLabel ?? "Select Offer",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorConst.primaryColor1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        maxHeight: 400,
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(8),
                                        itemCount: offers.length,
                                        itemBuilder: (context, index) {
                                          final offer =
                                              offers[index]
                                                  as Map<String, dynamic>;
                                          // Handle both 'amount' and 'rs' fields (prefer 'amount' for plans, 'rs' for DTH offers)
                                          final amount =
                                              offer['amount']?.toString() ??
                                              offer['rs']?.toString() ??
                                              '';
                                          final desc =
                                              offer['desc']?.toString() ??
                                              offer['description']
                                                  ?.toString() ??
                                              '';
                                          final validity =
                                              offer['validity']?.toString() ??
                                              '';
                                          final isSelected =
                                              selectedPlanAmount == amount;

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? colorConst.primaryColor1
                                                        .withOpacity(0.1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected
                                                    ? colorConst.primaryColor1
                                                    : Colors.grey.shade200,
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                amount.isNotEmpty
                                                    ? "₹$amount"
                                                    : "N/A",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? colorConst.primaryColor1
                                                      : Colors.black87,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 4),
                                                  if (desc.isNotEmpty)
                                                    Text(
                                                      desc,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  if (validity.isNotEmpty &&
                                                      validity != "N/A")
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 4,
                                                          ),
                                                      child: Text(
                                                        "Validity: $validity",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              trailing: amount.isNotEmpty
                                                  ? Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: colorConst
                                                            .primaryColor1,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "₹$amount",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                              onTap: amount.isNotEmpty
                                                  ? () {
                                                      _prefillAmount(amount);
                                                      setState(() {
                                                        selectedPlanName =
                                                            desc.isNotEmpty
                                                            ? desc
                                                            : "Offer";
                                                      });
                                                      _showInfoAlert(
                                                        "Selected: ₹$amount",
                                                      );
                                                    }
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Fetch Bill + Pay button logic
                            // IMPORTANT: Only show buttons when operator is selected (operatorFormConfig is available)
                            Builder(
                              builder: (context) {
                                // Don't show any buttons until operator is selected/fetched
                                if (operatorFormConfig == null) {
                                  print(
                                    '🔘 [BUILD_BUTTONS] No operator selected, hiding all buttons',
                                  );
                                  return SizedBox.shrink();
                                }

                                final currentLayout = _getCurrentLayout();
                                final billFetchMode = _getBillFetchMode();
                                final requireBillFetchFirst =
                                    _getRequireBillFetchFirst();

                                // Fetch Bill Button: Show when:
                                // 1. fetchBillButton === true
                                // 2. fetchBillEndpoint is non-empty
                                // 3. billFetchMode !== "manual_only"
                                // 4. Bill has NOT been fetched yet (hide after successful fetch)
                                final showFetchBillButton =
                                    currentLayout.fetchBillButton &&
                                    currentLayout
                                        .fetchBillEndpoint
                                        .isNotEmpty &&
                                    billFetchMode != "manual_only" &&
                                    !isBillFetched;

                                print(
                                  '🔘 [BUILD_BUTTONS] Fetch Bill Button Check:',
                                );
                                print(
                                  '   🔘 fetchBillButton: ${currentLayout.fetchBillButton}',
                                );
                                print(
                                  '   🔘 fetchBillEndpoint: "${currentLayout.fetchBillEndpoint}" (empty: ${currentLayout.fetchBillEndpoint.isEmpty})',
                                );
                                print('   🔘 billFetchMode: "$billFetchMode"');
                                print('   🔘 isBillFetched: $isBillFetched');
                                print(
                                  '   ✅ Will show fetchBillButton: $showFetchBillButton',
                                );

                                // Pay Button: Always show (like web), but:
                                // - If bill_fetch_mode === "fetch_only": Show ONLY after bill is fetched and amount is prefilled
                                // - Else: If require_bill_fetch_first === true: Hide initially, show after bill fetch
                                // - Else: Always show
                                final amountValue = _getAmountFromForm();
                                final hasPrefilledAmount =
                                    amountValue.isNotEmpty;

                                final showPayButton =
                                    billFetchMode == "fetch_only"
                                    ? (isBillFetched && hasPrefilledAmount)
                                    : (requireBillFetchFirst
                                          ? isBillFetched
                                          : true);

                                print('🔘 [BUILD_BUTTONS] Pay Button Check:');
                                print(
                                  '   🔘 requireBillFetchFirst: $requireBillFetchFirst',
                                );
                                print('   🔘 isBillFetched: $isBillFetched');
                                print(
                                  '   🔘 hasPrefilledAmount: $hasPrefilledAmount',
                                );
                                print(
                                  '   ✅ Will show payButton: $showPayButton',
                                );

                                return Column(
                                  children: [
                                    // Fetch Bill Button (if enabled)
                                    if (showFetchBillButton)
                                      Container(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : fetchBill,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.grey.shade900,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Fetch Bill",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Pay Button (always show when operator selected, like web)
                                    // Respect require_bill_fetch_first setting
                                    if (showPayButton) ...[
                                      if (showFetchBillButton)
                                        const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : performRecharge,
                                          icon: const Icon(
                                            Icons.payment,
                                            size: 18,
                                          ),
                                          label: const Text("Pay"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                colorConst.primaryColor1,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Loading overlay
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
