import 'package:shared_preferences/shared_preferences.dart';

Future<void> removeCredential()async {
  final prefs=await SharedPreferences.getInstance();
  prefs.remove('login_remember_me');
  prefs.remove('login_email');
  prefs.remove('login_password');
}