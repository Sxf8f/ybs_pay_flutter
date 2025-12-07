import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeLoginData(Map<String, dynamic> response) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt('user_id', response['user_id']);
  await prefs.setString('username', response['username']);
  await prefs.setInt('role_id', response['role_id']);
  await prefs.setString('role_name', response['role_name']);
  await prefs.setString('access_token', response['access']);
  await prefs.setString('refresh_token', response['refresh']);
}
