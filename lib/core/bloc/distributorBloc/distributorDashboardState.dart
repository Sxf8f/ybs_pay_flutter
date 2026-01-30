import 'package:equatable/equatable.dart';
import '../../models/distributorModels/distributorDashboardModel.dart';

abstract class DistributorDashboardState extends Equatable {
  @override
  List<Object> get props => [];
}

class DistributorDashboardInitial extends DistributorDashboardState {}

class DistributorDashboardLoading extends DistributorDashboardState {}

/// Emitted when we already have dashboard data, but we are fetching fresh data.
/// UI should keep showing the existing dashboard and optionally show a small
/// loading indicator (avoids "Loaded -> Loading -> Loaded" skeleton flash).
class DistributorDashboardRefreshing extends DistributorDashboardState {
  final DistributorDashboardResponse dashboard;

  DistributorDashboardRefreshing(this.dashboard);

  @override
  List<Object> get props => [dashboard];
}

class DistributorDashboardLoaded extends DistributorDashboardState {
  final DistributorDashboardResponse dashboard;

  DistributorDashboardLoaded(this.dashboard);

  @override
  List<Object> get props => [dashboard];
}

class DistributorDashboardError extends DistributorDashboardState {
  final String message;

  DistributorDashboardError(this.message);

  @override
  List<Object> get props => [message];
}

