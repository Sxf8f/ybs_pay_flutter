class DashboardStatisticsResponse {
  final bool success;
  final DashboardStatistics statistics;
  final PeriodInfo period;
  final String message;

  DashboardStatisticsResponse({
    required this.success,
    required this.statistics,
    required this.period,
    required this.message,
  });

  factory DashboardStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return DashboardStatisticsResponse(
      success: json['success'] ?? false,
      statistics: DashboardStatistics.fromJson(json['statistics'] ?? {}),
      period: PeriodInfo.fromJson(json['period'] ?? {}),
      message: json['message']?.toString() ?? '',
    );
  }
}

class DashboardStatistics {
  final StatisticItem success;
  final StatisticItem commission;
  final StatisticItem pending;
  final StatisticItem failed;

  DashboardStatistics({
    required this.success,
    required this.commission,
    required this.pending,
    required this.failed,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      success: StatisticItem.fromJson(json['success'] ?? {}),
      commission: StatisticItem.fromJson(json['commission'] ?? {}),
      pending: StatisticItem.fromJson(json['pending'] ?? {}),
      failed: StatisticItem.fromJson(json['failed'] ?? {}),
    );
  }
}

class StatisticItem {
  final String amount;
  final int count;
  final String formatted;

  StatisticItem({
    required this.amount,
    required this.count,
    required this.formatted,
  });

  factory StatisticItem.fromJson(Map<String, dynamic> json) {
    return StatisticItem(
      amount: json['amount']?.toString() ?? '0.00',
      count: json['count'] ?? 0,
      formatted: json['formatted']?.toString() ?? '₹0.00',
    );
  }
}

class PeriodInfo {
  final String? startDate;
  final String endDate;
  final String label;

  PeriodInfo({
    this.startDate,
    required this.endDate,
    required this.label,
  });

  factory PeriodInfo.fromJson(Map<String, dynamic> json) {
    return PeriodInfo(
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

