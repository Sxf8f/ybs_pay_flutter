import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/distributorRepository/distributorRepo.dart';
import 'distributorCommissionEvent.dart';
import 'distributorCommissionState.dart';

class DistributorCommissionBloc extends Bloc<DistributorCommissionEvent, DistributorCommissionState> {
  final DistributorRepository repository;

  DistributorCommissionBloc(this.repository) : super(DistributorCommissionInitial()) {
    on<FetchCommissionSlabEvent>(_onFetchCommissionSlab);
  }

  Future<void> _onFetchCommissionSlab(
    FetchCommissionSlabEvent event,
    Emitter<DistributorCommissionState> emit,
  ) async {
    emit(DistributorCommissionLoading());
    try {
      final commission = await repository.getCommissionSlab();
      emit(DistributorCommissionLoaded(commission));
    } catch (e) {
      emit(DistributorCommissionError(e.toString()));
    }
  }
}

