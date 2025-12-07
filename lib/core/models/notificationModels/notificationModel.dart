class NotificationStatsResponse {
  final bool success;
  final NotificationStats stats;

  NotificationStatsResponse({required this.success, required this.stats});

  factory NotificationStatsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationStatsResponse(
      success: json['success'] ?? false,
      stats: json['stats'] != null
          ? NotificationStats.fromJson(json['stats'])
          : NotificationStats(
              totalNotifications: 0,
              unreadNotifications: 0,
              readNotifications: 0,
            ),
    );
  }
}

class NotificationStats {
  final int totalNotifications;
  final int unreadNotifications;
  final int readNotifications;

  NotificationStats({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.readNotifications,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalNotifications: json['total_notifications'] ?? 0,
      unreadNotifications: json['unread_notifications'] ?? 0,
      readNotifications: json['read_notifications'] ?? 0,
    );
  }
}

class NotificationsResponse {
  final bool success;
  final List<NotificationItem> notifications;
  final int totalCount;
  final int unreadCount;

  NotificationsResponse({
    required this.success,
    required this.notifications,
    required this.totalCount,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] ?? false,
      notifications: json['notifications'] != null
          ? List<NotificationItem>.from(
              json['notifications'].map((x) => NotificationItem.fromJson(x)),
            )
          : [],
      totalCount: json['total_count'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class NotificationItem {
  final int id;
  final int notificationId;
  final String title;
  final String message;
  final String? redirectUrl;
  final String? image;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String sentBy;

  NotificationItem({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.message,
    this.redirectUrl,
    this.image,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.sentBy,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      notificationId: json['notification_id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      redirectUrl: json['redirect_url'],
      image: json['image'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      sentBy: json['sent_by'] ?? '',
    );
  }
}

class MarkReadResponse {
  final bool success;
  final String message;
  final int updatedCount;

  MarkReadResponse({
    required this.success,
    required this.message,
    required this.updatedCount,
  });

  factory MarkReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkReadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      updatedCount: json['updated_count'] ?? 0,
    );
  }
}
