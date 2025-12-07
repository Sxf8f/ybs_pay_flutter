import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/appRepository/appRepo.dart';
import 'appEvent.dart';
import 'appState.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository repository;

  AppBloc(this.repository) : super(AppInitial()) {
    on<FetchBannersEvent>(_onFetchBanners);
    on<FetchSettingsEvent>(_onFetchSettings);
  }

  Future<void> _onFetchBanners(
    FetchBannersEvent event,
    Emitter<AppState> emit,
  ) async {
    try {
      final banners = await repository.fetchBanners();
      final currentState = state;
      if (currentState is AppLoaded) {
        emit(currentState.copyWith(banners: banners));
      } else {
        emit(AppLoaded(banners: banners));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onFetchSettings(
    FetchSettingsEvent event,
    Emitter<AppState> emit,
  ) async {
    try {
      final settings = await repository.fetchSettings();
      final currentState = state;
      if (currentState is AppLoaded) {
        emit(currentState.copyWith(settings: settings));
      } else {
        emit(AppLoaded(settings: settings));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }
}
