class UserModel {
  final int userId;
  final String username;
  final String? name;
  final String? email;
  final String? phone;
  final int roleId;
  final String roleName;
  final String accessToken;
  final String refreshToken;
  final String? loginUserId;
  final String? loginType;

  UserModel({
    required this.userId,
    required this.username,
    this.name,
    this.email,
    this.phone,
    required this.roleId,
    required this.roleName,
    required this.accessToken,
    required this.refreshToken,
    this.loginUserId,
    this.loginType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int _toInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    return UserModel(
      userId: _toInt(json['user_id'], 0),
      username: json['username'] ?? json['login_user_id'] ?? '',
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      roleId: _toInt(json['role_id'], 0),
      roleName: json['role_name'] ?? '',
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
      loginUserId: json['login_user_id'],
      loginType: json['login_type'],
    );
  }
}

class LayoutModel {
  final Amount? amount;
  final List<dynamic>? fields;
  final List<ButtonModel>? buttons;
  final AutoOperator? autoOperator;
  final bool bookingButton;
  final DefaultNumber? defaultNumber;
  final bool paymentButton;
  final bool requestButton;
  final String bookingEndpoint;
  final String paymentEndpoint;
  final String requestEndpoint;
  final bool fetchBillButton;
  final OperatorDropdown? operatorDropdown;
  final String fetchBillEndpoint;
  final int operatorTypeId;
  final String operatorTypeName;
  final bool isActive;
  final String? icon;
  final String? lastUpdated;
  final String? billFetchMode;
  final bool? requireBillFetchFirst;
  final bool? amountEditableAfterFetch;
  final Map<String, dynamic>? operatorValidations;

  LayoutModel({
    this.amount,
    this.fields,
    this.buttons,
    this.autoOperator,
    required this.bookingButton,
    this.defaultNumber,
    required this.paymentButton,
    required this.requestButton,
    required this.bookingEndpoint,
    required this.paymentEndpoint,
    required this.requestEndpoint,
    required this.fetchBillButton,
    this.operatorDropdown,
    required this.fetchBillEndpoint,
    required this.operatorTypeId,
    required this.operatorTypeName,
    required this.isActive,
    this.icon,
    this.lastUpdated,
    this.billFetchMode,
    this.requireBillFetchFirst,
    this.amountEditableAfterFetch,
    this.operatorValidations,
  });

  factory LayoutModel.fromJson(Map<String, dynamic> json) {
    return LayoutModel(
      amount: json['amount'] != null ? Amount.fromJson(json['amount']) : null,
      fields: json['fields'] ?? [],
      buttons: json['buttons'] != null
          ? List<ButtonModel>.from(
              json['buttons'].map((b) => ButtonModel.fromJson(b)),
            )
          : [],
      autoOperator: json['auto_operator'] != null
          ? AutoOperator.fromJson(json['auto_operator'])
          : null,
      bookingButton: json['booking_button'] ?? false,
      defaultNumber: json['default_number'] != null
          ? DefaultNumber.fromJson(json['default_number'])
          : null,
      paymentButton: json['payment_button'] ?? false,
      requestButton: json['request_button'] ?? false,
      bookingEndpoint: json['booking_endpoint'] ?? '',
      paymentEndpoint: json['payment_endpoint'] ?? '',
      requestEndpoint: json['request_endpoint'] ?? '',
      fetchBillButton: json['fetch_bill_button'] ?? false,
      operatorDropdown: json['operator_dropdown'] != null
          ? OperatorDropdown.fromJson(json['operator_dropdown'])
          : null,
      fetchBillEndpoint: json['fetch_bill_endpoint'] ?? '',
      operatorTypeId: json['operator_type_id'] ?? 0,
      operatorTypeName: json['operator_type_name'] ?? '',
      isActive: json['is_active'] ?? false,
      icon: json['icon'],
      lastUpdated: json['last_updated'],
      billFetchMode: json['bill_fetch_mode'],
      requireBillFetchFirst: json['require_bill_fetch_first'],
      amountEditableAfterFetch: json['amount_editable_after_fetch'],
      operatorValidations: json['operator_validations'] != null
          ? Map<String, dynamic>.from(json['operator_validations'])
          : null,
    );
  }
}

class Amount {
  final bool enabled;
  final bool editable; // Deprecated - kept for backward compatibility
  final bool? editableAfterFetch; // Whether editable AFTER bill fetch
  final bool? initialEditable; // Whether editable initially (should always be true)

  Amount({
    required this.enabled,
    required this.editable,
    this.editableAfterFetch,
    this.initialEditable,
  });

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      enabled: json['enabled'] ?? false,
      editable: json['editable'] ?? json['editable_after_fetch'] ?? true, // Backward compatibility
      editableAfterFetch: json['editable_after_fetch'],
      initialEditable: json['initial_editable'] ?? true,
    );
  }
}

class ButtonModel {
  final String key;
  final String type;
  final String label;
  final String function;

  ButtonModel({
    required this.key,
    required this.type,
    required this.label,
    required this.function,
  });

  factory ButtonModel.fromJson(Map<String, dynamic> json) {
    return ButtonModel(
      key: json['key'] ?? '',
      type: json['type'] ?? '',
      label: json['label'] ?? '',
      function: json['function'] ?? '',
    );
  }
}

class AutoOperator {
  final bool enabled;
  final String endpoint;

  AutoOperator({required this.enabled, required this.endpoint});

  factory AutoOperator.fromJson(Map<String, dynamic> json) {
    return AutoOperator(
      enabled: json['enabled'] ?? false,
      endpoint: json['endpoint'] ?? '',
    );
  }
}

class OperatorDropdown {
  final bool enabled;
  final String endpoint;

  OperatorDropdown({required this.enabled, required this.endpoint});

  factory OperatorDropdown.fromJson(Map<String, dynamic> json) {
    return OperatorDropdown(
      enabled: json['enabled'] ?? false,
      endpoint: json['endpoint'] ?? '',
    );
  }
}

class DefaultNumber {
  final String hint;
  final String name;
  final String remark;
  final bool enabled;

  DefaultNumber({
    required this.hint,
    required this.name,
    required this.remark,
    required this.enabled,
  });

  factory DefaultNumber.fromJson(Map<String, dynamic> json) {
    return DefaultNumber(
      hint: json['hint'] ?? '',
      name: json['name'] ?? '',
      remark: json['remark'] ?? '',
      enabled: json['enabled'] ?? false,
    );
  }
}

class BillInfo {
  final bool success;
  final String name;
  final String amount;
  final String billDate;
  final String dueDate;
  final String billNumber;

  BillInfo({
    required this.success,
    required this.name,
    required this.amount,
    required this.billDate,
    required this.dueDate,
    required this.billNumber,
  });

  factory BillInfo.fromJson(Map<String, dynamic> json) {
    return BillInfo(
      success: json['success'] ?? false,
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      billDate: json['bill_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      billNumber: json['bill_number'] ?? '',
    );
  }
}

class DthInfo {
  final String tel;
  final String operator;
  final List<DthRecord> records;
  final int status;

  DthInfo({
    required this.tel,
    required this.operator,
    required this.records,
    required this.status,
  });

  factory DthInfo.fromJson(Map<String, dynamic> json) {
    return DthInfo(
      tel: json['tel'] ?? '',
      operator: json['operator'] ?? '',
      records: json['records'] != null
          ? List<DthRecord>.from(
              json['records'].map((x) => DthRecord.fromJson(x)),
            )
          : [],
      status: json['status'] ?? 0,
    );
  }
}

class DthRecord {
  final String monthlyRecharge;
  final String balance;
  final String customerName;
  final String status;
  final String nextRechargeDate;
  final String planName;
  final String lastRechargeAmount;

  DthRecord({
    required this.monthlyRecharge,
    required this.balance,
    required this.customerName,
    required this.status,
    required this.nextRechargeDate,
    required this.planName,
    required this.lastRechargeAmount,
  });

  factory DthRecord.fromJson(Map<String, dynamic> json) {
    return DthRecord(
      monthlyRecharge: json['MonthlyRecharge'] ?? '',
      balance: json['Balance'] ?? '',
      customerName: json['customerName'] ?? '',
      status: json['status'] ?? '',
      nextRechargeDate: json['NextRechargeDate'] ?? '',
      planName: json['planname'] ?? '',
      lastRechargeAmount: json['lastrechargeamount'] ?? '',
    );
  }
}

class DthPlans {
  final Map<String, List<DthPlan>> records;
  final int status;

  DthPlans({required this.records, required this.status});

  factory DthPlans.fromJson(Map<String, dynamic> json) {
    Map<String, List<DthPlan>> records = {};
    if (json['records'] != null) {
      json['records'].forEach((key, value) {
        if (value is List) {
          records[key] = List<DthPlan>.from(
            value.map((x) => DthPlan.fromJson(x)),
          );
        }
      });
    }
    return DthPlans(records: records, status: json['status'] ?? 0);
  }
}

class DthPlan {
  final dynamic rs; // Can be String or Map<String, String>
  final String desc;
  final String planName;
  final String lastUpdate;
  final String? validity; // For mobile plans

  DthPlan({
    required this.rs,
    required this.desc,
    required this.planName,
    required this.lastUpdate,
    this.validity,
  });

  factory DthPlan.fromJson(Map<String, dynamic> json) {
    dynamic rs;
    if (json['rs'] != null) {
      if (json['rs'] is String) {
        // Mobile plan format: "rs": "10"
        rs = json['rs'];
      } else if (json['rs'] is Map) {
        // DTH plan format: "rs": {"1 MONTHS": "150"}
        Map<String, String> rsMap = {};
        json['rs'].forEach((key, value) {
          rsMap[key] = value.toString();
        });
        rs = rsMap;
      }
    }

    return DthPlan(
      rs: rs,
      desc: json['desc'] ?? '',
      planName: json['plan_name'] ?? '',
      lastUpdate: json['last_update'] ?? '',
      validity: json['validity'],
    );
  }

  // Helper method to get amount as string
  String getAmount() {
    if (rs is String) {
      return rs as String;
    } else if (rs is Map<String, String>) {
      return (rs as Map<String, String>).values.first;
    }
    return '0';
  }
}

class DthHeavyRefresh {
  final String tel;
  final String operator;
  final DthRefreshRecord records;
  final int status;

  DthHeavyRefresh({
    required this.tel,
    required this.operator,
    required this.records,
    required this.status,
  });

  factory DthHeavyRefresh.fromJson(Map<String, dynamic> json) {
    return DthHeavyRefresh(
      tel: json['tel'] ?? '',
      operator: json['operator'] ?? '',
      records: DthRefreshRecord.fromJson(json['records'] ?? {}),
      status: json['status'] ?? 0,
    );
  }
}

class DthRefreshRecord {
  final String desc;
  final String customerName;
  final int status;

  DthRefreshRecord({
    required this.desc,
    required this.customerName,
    required this.status,
  });

  factory DthRefreshRecord.fromJson(Map<String, dynamic> json) {
    return DthRefreshRecord(
      desc: json['desc'] ?? '',
      customerName: json['customerName'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}
