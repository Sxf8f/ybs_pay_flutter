class DistributorDashboardResponse {
  final bool success;
  final DistributorDashboard data;

  DistributorDashboardResponse({
    required this.success,
    required this.data,
  });

  factory DistributorDashboardResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 [Dashboard Response] Parsing response JSON:');
    print('   - success: ${json['success']}');
    print('   - data type: ${json['data']?.runtimeType}');
    print('   - data content: ${json['data']}');
    
    if (json['data'] == null) {
      print('   ⚠️ WARNING: data is null!');
      return DistributorDashboardResponse(
        success: json['success'] ?? false,
        data: DistributorDashboard.fromJson({}),
      );
    }
    
    if (json['data'] is! Map<String, dynamic>) {
      print('   ❌ ERROR: data is not a Map! Type: ${json['data'].runtimeType}');
      print('   Attempting to handle...');
      // If data is not a map, create empty dashboard
      return DistributorDashboardResponse(
        success: json['success'] ?? false,
        data: DistributorDashboard.fromJson({}),
      );
    }
    
    return DistributorDashboardResponse(
      success: json['success'] ?? false,
      data: DistributorDashboard.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DistributorDashboard {
  final double balance;
  final double todaysFundTransfer;
  final double todaysPurchase;
  final double todaysEarning;
  final double pendingPurchase;
  final List<RoleSummary> roleSummary;
  final TodaysReport? todaysReport;

  DistributorDashboard({
    required this.balance,
    required this.todaysFundTransfer,
    required this.todaysPurchase,
    required this.todaysEarning,
    required this.pendingPurchase,
    required this.roleSummary,
    this.todaysReport,
  });

  factory DistributorDashboard.fromJson(Map<String, dynamic> json) {
    print('🔍 [Dashboard Model] Parsing dashboard JSON:');
    print('   - balance: ${json['balance']} (type: ${json['balance'].runtimeType})');
    print('   - todays_transfer: ${json['todays_transfer']} (type: ${json['todays_transfer']?.runtimeType})');
    print('   - todays_purchase: ${json['todays_purchase']} (type: ${json['todays_purchase']?.runtimeType})');
    print('   - todays_earning: ${json['todays_earning']} (type: ${json['todays_earning']?.runtimeType})');
    print('   - pending_purchase: ${json['pending_purchase']} (type: ${json['pending_purchase']?.runtimeType})');
    print('   - role_summary: ${json['role_summary']} (type: ${json['role_summary']?.runtimeType})');
    print('   - todays_report: ${json['todays_report']} (type: ${json['todays_report']?.runtimeType})');
    print('   - All keys in json: ${json.keys.toList()}');

    // Parse todaysReport only if it exists and is a Map
    TodaysReport? parsedTodaysReport;
    if (json['todays_report'] != null && json['todays_report'] is Map<String, dynamic>) {
      try {
        parsedTodaysReport = TodaysReport.fromJson(json['todays_report'] as Map<String, dynamic>);
        print('   ✅ Successfully parsed todays_report');
      } catch (e) {
        print('   ⚠️ Error parsing todays_report: $e');
        parsedTodaysReport = null;
      }
    } else {
      print('   ℹ️ todays_report is null or not a Map, skipping');
    }

    return DistributorDashboard(
      balance: (json['balance'] is int)
          ? (json['balance'] as int).toDouble()
          : (json['balance'] is double)
              ? json['balance']
              : double.tryParse(json['balance'].toString()) ?? 0.0,
      todaysFundTransfer: (json['todays_transfer'] is int)
          ? (json['todays_transfer'] as int).toDouble()
          : (json['todays_transfer'] is double)
              ? json['todays_transfer']
              : double.tryParse(json['todays_transfer'].toString()) ?? 0.0,
      todaysPurchase: (json['todays_purchase'] is int)
          ? (json['todays_purchase'] as int).toDouble()
          : (json['todays_purchase'] is double)
              ? json['todays_purchase']
              : double.tryParse(json['todays_purchase'].toString()) ?? 0.0,
      todaysEarning: (json['todays_earning'] is int)
          ? (json['todays_earning'] as int).toDouble()
          : (json['todays_earning'] is double)
              ? json['todays_earning']
              : double.tryParse(json['todays_earning'].toString()) ?? 0.0,
      pendingPurchase: (json['pending_purchase'] is int)
          ? (json['pending_purchase'] as int).toDouble()
          : (json['pending_purchase'] is double)
              ? json['pending_purchase']
              : double.tryParse(json['pending_purchase'].toString()) ?? 0.0,
      roleSummary: (json['role_summary'] as List<dynamic>?)
              ?.map((e) => RoleSummary.fromJson(e))
              .toList() ??
          [],
      todaysReport: parsedTodaysReport,
    );
  }
}

class RoleSummary {
  final String roleName;
  final int totalStatus;
  final int totalTxns;

  RoleSummary({
    required this.roleName,
    required this.totalStatus,
    required this.totalTxns,
  });

  factory RoleSummary.fromJson(Map<String, dynamic> json) {
    print('   🔍 [RoleSummary] Parsing: $json');
    return RoleSummary(
      roleName: json['role_name'] ?? json['user__role__name'] ?? '',
      totalStatus: (json['total_status'] is int)
          ? json['total_status']
          : (json['total_status'] is String)
              ? int.tryParse(json['total_status']) ?? 0
              : 0,
      totalTxns: (json['total_txns'] is int)
          ? json['total_txns']
          : (json['total_txns'] is String)
              ? int.tryParse(json['total_txns']) ?? 0
              : 0,
    );
  }
}

class TodaysReport {
  final List<String> labels;
  final List<int> values;

  TodaysReport({
    required this.labels,
    required this.values,
  });

  factory TodaysReport.fromJson(Map<String, dynamic> json) {
    return TodaysReport(
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      values: (json['values'] as List<dynamic>?)
              ?.map((e) => (e is int) ? e : int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
    );
  }
}


