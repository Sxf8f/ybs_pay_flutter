import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/notificationModels/notificationModel.dart';
import '../../auth/httpClient.dart';

class NotificationRepository {
  Future<NotificationStatsResponse> fetchNotificationStats() async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/notification-stats-android/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return NotificationStatsResponse.fromJson(data);
    } else {
      throw Exception(
        'Failed to fetch notification stats: ${response.statusCode}',
      );
    }
  }

  Future<NotificationsResponse> fetchNotifications() async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/user-notifications-android/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return NotificationsResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    }
  }

  Future<MarkReadResponse> markAllNotificationsRead() async {
    final response = await AuthenticatedHttpClient.post(
      Uri.parse(
        '${AssetsConst.apiBase}api/mark-all-notifications-read-android/',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: {},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MarkReadResponse.fromJson(data);
    } else {
      throw Exception(
        'Failed to mark notifications as read: ${response.statusCode}',
      );
    }
  }
}
