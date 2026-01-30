import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dashboardRepository/dashboardRepo.dart';
import 'dashboardEvent.dart';
import 'dashboardState.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardBloc({required this.dashboardRepository}) : super(DashboardInitial()) {
    on<FetchDashboardStatistics>((event, emit) async {
      emit(DashboardLoading());
      try {
        final statistics = await dashboardRepository.fetchStatistics(
          startDate: event.startDate,
          endDate: event.endDate,
          period: event.period,
        );
        emit(DashboardStatisticsLoaded(statistics: statistics));
      } catch (e) {
        emit(DashboardError(message: e.toString()));
      }
    });
  }
}

