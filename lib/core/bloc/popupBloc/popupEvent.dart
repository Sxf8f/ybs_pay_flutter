import 'package:equatable/equatable.dart';

abstract class PopupEvent extends Equatable {
  const PopupEvent();

  @override
  List<Object> get props => [];
}

class CheckPopupEvent extends PopupEvent {
  const CheckPopupEvent();
}

class MarkPopupAsSeenEvent extends PopupEvent {
  final int popupId;

  const MarkPopupAsSeenEvent(this.popupId);

  @override
  List<Object> get props => [popupId];
}

class DismissPopupEvent extends PopupEvent {
  const DismissPopupEvent();
}

