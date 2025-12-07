import 'package:shared_preferences/shared_preferences.dart';


Future<void> removeLoginData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_id');
  await prefs.remove('username');
  await prefs.remove('role_id');
  await prefs.remove('role_name');
  await prefs.remove('access_token');
  await prefs.remove('refresh_token');
}