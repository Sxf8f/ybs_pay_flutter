import 'dart:convert';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/core/sharedPreference/storeUserData.dart';
import '../../models/authModels/userModel.dart';

class signInAuthRepository {
  Future<UserModel> login(String username, String password) async {
    final url = Uri.parse("${AssetsConst.apiBase}api/login/");

    final response = await http.post(url, body: {
      'username': username,
      'password': password,
    });
    final data = json.decode(response.body);
      print('data logged :: ${data}');
    if (response.statusCode == 200) {
      await storeLoginData(data);
      return UserModel.fromJson(data);
    } else {
      print('data logged :: ${data}');
      print(data['non_field_errors'][0]);
      // print(data['error']['non_field_errors']);
      print('344');
      throw Text(data['non_field_errors'][0]);
    }
  }
}
