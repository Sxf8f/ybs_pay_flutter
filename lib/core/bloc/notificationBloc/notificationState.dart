import 'package:equatable/equatable.dart';
import '../../models/notificationModels/notificationModel.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationStatsLoaded extends NotificationState {
  final NotificationStats stats;

  const NotificationStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class NotificationsLoaded extends NotificationState {
  final NotificationsResponse notificationsResponse;

  const NotificationsLoaded({required this.notificationsResponse});

  @override
  List<Object?> get props => [notificationsResponse];
}

class NotificationsMarkedRead extends NotificationState {
  final int updatedCount;

  const NotificationsMarkedRead({required this.updatedCount});

  @override
  List<Object?> get props => [updatedCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
