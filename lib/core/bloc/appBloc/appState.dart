import 'package:equatable/equatable.dart';
import '../../models/appModels/bannersModel.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

class AppLoaded extends AppState {
  final List<Banner>? banners;
  final Settings? settings;

  const AppLoaded({this.banners, this.settings});

  AppLoaded copyWith({List<Banner>? banners, Settings? settings}) {
    return AppLoaded(
      banners: banners ?? this.banners,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object> get props => [
    banners ?? <Banner>[],
    settings?.logo?.image ?? '',
    settings?.appLogo?.image ?? '',
  ];
}

class AppError extends AppState {
  final String message;

  const AppError(this.message);

  @override
  List<Object> get props => [message];
}
