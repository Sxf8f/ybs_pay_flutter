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
    FetchLayoutsEvent event,
    Emitter<LayoutState> emit,
  ) async {
    print('🔍 LAYOUT BLOC: FetchLayoutsEvent received');
    print('   Current state: ${state.runtimeType}');
    emit(LayoutLoading());
    print('   📡 Emitted LayoutLoading state');

    try {
      print('   📡 Calling repository.fetchLayouts()...');
      final layouts = await repository.fetchLayouts();
      print('   ✅ Layouts fetched successfully: ${layouts.length} layouts');
      emit(LayoutLoaded(layouts));
      print('   ✅ Emitted LayoutLoaded state with ${layouts.length} layouts');
    } catch (e, stackTrace) {
      print('   ❌ LAYOUT BLOC ERROR:');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      emit(LayoutError(e.toString()));
      print('   ❌ Emitted LayoutError state');
    }
  }
}
