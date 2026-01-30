import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/appRepository/appRepo.dart';
import 'appEvent.dart';
import 'appState.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository repository;

  AppBloc(this.repository) : super(AppInitial()) {
    on<FetchBannersEvent>(_onFetchBanners);
    on<FetchSettingsEvent>(_onFetchSettings);
    on<FetchNewsEvent>(_onFetchNews);
  }

  Future<void> _onFetchBanners(
    FetchBannersEvent event,
    Emitter<AppState> emit,
  ) async {
    // Prevent refetching if banners are already loaded
    final currentState = state;
    if (currentState is AppLoaded && currentState.banners != null && currentState.banners!.isNotEmpty) {
      print('📸 [APP_BLOC] Banners already loaded, skipping refetch');
      return;
    }
    
    try {
      print('📸 [APP_BLOC] Fetching banners...');
      final banners = await repository.fetchBanners();
      print('📸 [APP_BLOC] Banners fetched successfully: ${banners.length} banners');
      
      if (currentState is AppLoaded) {
        emit(currentState.copyWith(banners: banners));
      } else {
        emit(AppLoaded(banners: banners));
      }
    } catch (e) {
      print('📸 [APP_BLOC] Error fetching banners: $e');
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onFetchSettings(
    FetchSettingsEvent event,
    Emitter<AppState> emit,
  ) async {
    print('🔍 APP BLOC: _onFetchSettings called');
    print('  Current state: ${state.runtimeType}');
    
    try {
      print('  📡 Calling repository.fetchSettings()...');
      final settings = await repository.fetchSettings();
      print('  ✅ Settings fetched successfully');
      print('  Settings: $settings');
      print('  Logo: ${settings.logo}');
      print('  Logo Image: ${settings.logo?.image}');
      
      final currentState = state;
      if (currentState is AppLoaded) {
        print('  ✅ Current state is AppLoaded, updating settings...');
        emit(currentState.copyWith(settings: settings));
      } else {
        print('  ✅ Current state is not AppLoaded, creating new AppLoaded...');
        emit(AppLoaded(settings: settings));
      }
      print('  ✅ State emitted: AppLoaded with settings');
    } catch (e, stackTrace) {
      print('  ❌ Error in _onFetchSettings: $e');
      print('  Error type: ${e.runtimeType}');
      print('  Stack trace: $stackTrace');
      print('  ❌ Emitting AppError state with message: ${e.toString()}');
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onFetchNews(
    FetchNewsEvent event,
    Emitter<AppState> emit,
  ) async {
    print('📰 [APP_BLOC] _onFetchNews called');
    try {
      final news = await repository.fetchNews();
      print('📰 [APP_BLOC] News fetched successfully');
      print('   - hasNews: ${news.hasNews}');
      print('   - news count: ${news.news.length}');
      final currentState = state;
      if (currentState is AppLoaded) {
        print('📰 [APP_BLOC] Current state is AppLoaded, updating news...');
        emit(currentState.copyWith(news: news));
      } else {
        print('📰 [APP_BLOC] Current state is not AppLoaded, creating new AppLoaded with news...');
        emit(AppLoaded(news: news));
      }
      print('📰 [APP_BLOC] State emitted with news');
    } catch (e, stackTrace) {
      print('📰 [APP_BLOC] Error fetching news: $e');
      print('   Stack trace: $stackTrace');
      // On error, still emit AppLoaded with null news (will hide ticker)
      final currentState = state;
      if (currentState is AppLoaded) {
        emit(currentState.copyWith(news: null));
      } else {
        emit(AppLoaded(news: null));
      }
    }
  }
}
