import 'dart:convert';
import 'package:http/http.dart' as http;

class LogoutService {
  Future<void> logoutRemote({
    required String session,
    required int sessionID,
    required int userID,
  }) async {
    final url = Uri.parse("http://ybspay.co.in/App/Logout");

    final body = jsonEncode({
      "sessType": "1",
      "appid": "ROUNDPAYAPPID13APR20191351",
      "imei": "fqfHSulb0fvbegE",
      "isUPI": false,
      "loginTypeID": "1",
      "regKey": "",
      "serialNo": "010e9b5761b54748",
      "session": session,
      "sessionID": sessionID.toString(),
      "uid": 0,
      "userID": userID.toString(),
      "version": "1.0"
    });

    final response = await http.post(url, headers: {
      'Content-Type': 'application/json',
    }, body: body);

    if (response.statusCode != 200) {
      throw Exception('Logout failed');
    }
  }
}
