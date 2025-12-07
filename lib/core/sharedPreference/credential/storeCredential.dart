import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future storeCredential(TextEditingController userController, TextEditingController passController) async{
  final prefs=await SharedPreferences.getInstance();
  await prefs.setBool('login_remember_me', true);
  await prefs.setString('login_email', userController.text);
  await prefs.setString('login_password', passController.text);

}