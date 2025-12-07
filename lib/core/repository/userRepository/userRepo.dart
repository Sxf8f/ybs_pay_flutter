import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../const/assets_const.dart';
import '../../models/userModels/userDetailsModel.dart';

class UserRepository {
  Future<UserDetails> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${AssetsConst.apiBase}api/user-details-android/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userResponse = UserDetailsResponse.fromJson(data);
      return userResponse.user;
    } else {
      throw Exception('Failed to load user details: ${response.statusCode}');
    }
  }
}
