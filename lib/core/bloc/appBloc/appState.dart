import 'package:equatable/equatable.dart';
import '../../models/appModels/bannersModel.dart';
import '../../models/appModels/newsModel.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

class AppLoaded extends AppState {
  final List<Banner>? banners;
  final Settings? settings;
  final NewsResponse? news;

  const AppLoaded({this.banners, this.settings, this.news});

  AppLoaded copyWith({List<Banner>? banners, Settings? settings, NewsResponse? news}) {
    return AppLoaded(
      banners: banners ?? this.banners,
      settings: settings ?? this.settings,
      news: news ?? this.news,
    );
  }

  @override
  List<Object> get props => [
    banners ?? <Banner>[],
    settings?.logo?.image ?? '',
    settings?.appLogo?.image ?? '',
    news?.hasNews ?? false,
  ];
}

class AppError extends AppState {
  final String message;

  const AppError(this.message);

  @override
  List<Object> get props => [message];
}
