import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/distributorRepository/distributorRepo.dart';
import 'distributorDashboardEvent.dart';
import 'distributorDashboardState.dart';

class DistributorDashboardBloc extends Bloc<DistributorDashboardEvent, DistributorDashboardState> {
  final DistributorRepository repository;

  DistributorDashboardBloc(this.repository) : super(DistributorDashboardInitial()) {
    on<FetchDistributorDashboardEvent>(_onFetchDashboard);
  }

  Future<void> _onFetchDashboard(
    FetchDistributorDashboardEvent event,
    Emitter<DistributorDashboardState> emit,
  ) async {
    print('🔄 [Dashboard BLoC] Fetching dashboard...');
    // If we already have data, keep showing it while refreshing to avoid UI flashes.
    final previousState = state;
    if (previousState is DistributorDashboardLoaded) {
      emit(DistributorDashboardRefreshing(previousState.dashboard));
    } else if (previousState is DistributorDashboardRefreshing) {
      // Keep refreshing state; no need to emit again.
    } else {
      emit(DistributorDashboardLoading());
    }
    try {
      print('🔄 [Dashboard BLoC] Calling repository.fetchDashboard()...');
      final dashboard = await repository.fetchDashboard();
      print('✅ [Dashboard BLoC] Dashboard fetched successfully');
      print('   - Success: ${dashboard.success}');
      print('   - Balance: ${dashboard.data.balance}');
      print('   - Role Summary count: ${dashboard.data.roleSummary.length}');
      emit(DistributorDashboardLoaded(dashboard));
    } catch (e, stackTrace) {
      print('❌ [Dashboard BLoC] Error fetching dashboard: $e');
      print('❌ [Dashboard BLoC] Stack trace: $stackTrace');
      // If this was a background refresh, keep the old data instead of swapping to an error screen.
      if (previousState is DistributorDashboardLoaded) {
        emit(DistributorDashboardLoaded(previousState.dashboard));
      } else if (previousState is DistributorDashboardRefreshing) {
        emit(DistributorDashboardLoaded(previousState.dashboard));
      } else {
        emit(DistributorDashboardError(e.toString()));
      }
    }
  }
}

