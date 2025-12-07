import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/notificationRepository/notificationRepo.dart';
import 'notificationEvent.dart';
import 'notificationState.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository,
      super(const NotificationInitial()) {
    on<FetchNotificationStatsEvent>(_onFetchNotificationStats);
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkAllNotificationsReadEvent>(_onMarkAllNotificationsRead);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
  }

  Future<void> _onFetchNotificationStats(
    FetchNotificationStatsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());
      final statsResponse = await _notificationRepository
          .fetchNotificationStats();
      emit(NotificationStatsLoaded(stats: statsResponse.stats));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('Fetching notifications...');
      emit(const NotificationLoading());
      final notificationsResponse = await _notificationRepository
          .fetchNotifications();
      print(
        'Notifications fetched successfully: ${notificationsResponse.notifications.length}',
      );
      emit(NotificationsLoaded(notificationsResponse: notificationsResponse));
    } catch (e) {
      print('Error fetching notifications: $e');
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final markReadResponse = await _notificationRepository
          .markAllNotificationsRead();
      emit(
        NotificationsMarkedRead(updatedCount: markReadResponse.updatedCount),
      );

      // Refresh notifications after marking as read
      add(const FetchNotificationsEvent());
      add(const FetchNotificationStatsEvent());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    add(const FetchNotificationStatsEvent());
    add(const FetchNotificationsEvent());
  }
}
