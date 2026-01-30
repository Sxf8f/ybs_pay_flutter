import 'package:equatable/equatable.dart';
import '../../models/popupModels/popupModel.dart';

abstract class PopupState extends Equatable {
  const PopupState();

  @override
  List<Object> get props => [];
}

class PopupInitial extends PopupState {}

class PopupLoading extends PopupState {}

class PopupAvailable extends PopupState {
  final Popup popup;

  const PopupAvailable(this.popup);

  @override
  List<Object> get props => [popup];
}

class PopupNotAvailable extends PopupState {
  const PopupNotAvailable();
}

class PopupMarkedAsSeen extends PopupState {
  final int popupId;

  const PopupMarkedAsSeen(this.popupId);

  @override
  List<Object> get props => [popupId];
}

class PopupDismissed extends PopupState {
  const PopupDismissed();
}

class PopupError extends PopupState {
  final String message;

  const PopupError(this.message);

  @override
  List<Object> get props => [message];
}

