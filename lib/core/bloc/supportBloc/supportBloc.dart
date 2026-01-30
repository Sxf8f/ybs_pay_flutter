import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/supportRepository/supportRepo.dart';
import 'supportEvent.dart';
import 'supportState.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository repository;

  SupportBloc(this.repository) : super(SupportInitial()) {
    on<FetchSupportInfoEvent>(_onFetchSupportInfo);
  }

  Future<void> _onFetchSupportInfo(
    FetchSupportInfoEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(SupportLoading());
    try {
      final response = await repository.getSupportInfo();
      if (response.success) {
        emit(SupportLoaded(data: response.data));
      } else {
        emit(SupportError('Failed to fetch support information'));
      }
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }
}

