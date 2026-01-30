import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/popupRepository/popupRepo.dart';
import 'popupEvent.dart';
import 'popupState.dart';

class PopupBloc extends Bloc<PopupEvent, PopupState> {
  final PopupRepository repository;

  PopupBloc(this.repository) : super(PopupInitial()) {
    on<CheckPopupEvent>(_onCheckPopup);
    on<MarkPopupAsSeenEvent>(_onMarkPopupAsSeen);
    on<DismissPopupEvent>(_onDismissPopup);
  }

  Future<void> _onCheckPopup(
    CheckPopupEvent event,
    Emitter<PopupState> emit,
  ) async {
    emit(PopupLoading());
    try {
      final response = await repository.checkPopup();
      
      if (response.hasPopup && response.popup != null) {
        emit(PopupAvailable(response.popup!));
      } else {
        emit(PopupNotAvailable());
      }
    } catch (e) {
      // If error occurs, just don't show popup (fail silently)
      // This prevents blocking app launch if popup API fails
      emit(PopupNotAvailable());
    }
  }

  Future<void> _onMarkPopupAsSeen(
    MarkPopupAsSeenEvent event,
    Emitter<PopupState> emit,
  ) async {
    try {
      await repository.markPopupAsSeen(event.popupId);
      emit(PopupMarkedAsSeen(event.popupId));
    } catch (e) {
      // Even if marking as seen fails, dismiss the popup
      emit(PopupDismissed());
    }
  }

  Future<void> _onDismissPopup(
    DismissPopupEvent event,
    Emitter<PopupState> emit,
  ) async {
    emit(PopupDismissed());
  }
}

