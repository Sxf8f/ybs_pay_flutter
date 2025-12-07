import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../const/assets_const.dart';
import '../../models/notificationModels/notificationModel.dart';

class NotificationRepository {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<NotificationStatsResponse> fetchNotificationStats() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${AssetsConst.apiBase}api/notification-stats-android/'),
      headers: {
        'Authorization': 'Bearer $token',
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
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${AssetsConst.apiBase}api/user-notifications-android/'),
      headers: {
        'Authorization': 'Bearer $token',
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
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(
        '${AssetsConst.apiBase}api/mark-all-notifications-read-android/',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
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
