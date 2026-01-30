import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchDashboardStatistics extends DashboardEvent {
  final String? startDate;
  final String? endDate;
  final String? period;

  FetchDashboardStatistics({
    this.startDate,
    this.endDate,
    this.period,
  });

  @override
  List<Object> get props => [
        startDate ?? '',
        endDate ?? '',
        period ?? '',
      ];
}

