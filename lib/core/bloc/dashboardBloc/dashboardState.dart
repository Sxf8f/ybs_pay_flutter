import 'package:equatable/equatable.dart';
import '../../models/dashboardModels/dashboardModel.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardStatisticsLoaded extends DashboardState {
  final DashboardStatisticsResponse statistics;

  DashboardStatisticsLoaded({required this.statistics});

  @override
  List<Object> get props => [statistics];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}

