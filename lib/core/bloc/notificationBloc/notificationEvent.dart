import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationStatsEvent extends NotificationEvent {
  const FetchNotificationStatsEvent();
}

class FetchNotificationsEvent extends NotificationEvent {
  const FetchNotificationsEvent();
}

class MarkAllNotificationsReadEvent extends NotificationEvent {
  const MarkAllNotificationsReadEvent();
}

class RefreshNotificationsEvent extends NotificationEvent {
  const RefreshNotificationsEvent();
}
