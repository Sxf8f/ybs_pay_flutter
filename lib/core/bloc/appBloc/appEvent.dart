import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class FetchBannersEvent extends AppEvent {
  const FetchBannersEvent();
}

class FetchSettingsEvent extends AppEvent {
  const FetchSettingsEvent();
}
