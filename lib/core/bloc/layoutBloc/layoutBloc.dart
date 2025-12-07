// lib/blocs/layout/layout_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/layoutRepository/layoutRepo.dart';
import 'layoutEvent.dart';
import 'layoutState.dart';


class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  final LayoutRepository repository;

  LayoutBloc(this.repository) : super(LayoutInitial()) {
    on<FetchLayoutsEvent>(_onFetchLayouts);
  }

  Future<void> _onFetchLayouts(
      FetchLayoutsEvent event, Emitter<LayoutState> emit) async {
    emit(LayoutLoading());
    try {
      final layouts = await repository.fetchLayouts();
      emit(LayoutLoaded(layouts));
    } catch (e) {
      emit(LayoutError(e.toString()));
    }
  }
}
