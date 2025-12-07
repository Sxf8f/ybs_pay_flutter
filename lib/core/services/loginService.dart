import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  Future<Map<String, dynamic>> login({
    required String userID,
    required String password,
  }) async {
    final url = Uri.parse('http://ybspay.co.in/App/Login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "appid": "ROUNDPAYAPPID13APR20191351",
        "domain": "ybspay.co.in",
        "imei": "fqfHSulb0fvbegE",
        "loginTypeID": 1,
        "password": password,
        "regKey": "",
        "serialNo": "010e9b5761b54748",
        "userID": userID,
        "version": "1.0"
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }
}
