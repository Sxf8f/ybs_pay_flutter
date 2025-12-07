import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../const/assets_const.dart';
import '../../models/appModels/bannersModel.dart';

class AppRepository {
  Future<List<Banner>> fetchBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('${AssetsConst.apiBase}api/website-banners-android/'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final bannersResponse = BannersResponse.fromJson(data);
      return bannersResponse.banners;
    } else {
      throw Exception('Failed to load banners: ${response.statusCode}');
    }
  }

  Future<Settings> fetchSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('${AssetsConst.apiBase}api/website-settings-android/'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final settingsResponse = SettingsResponse.fromJson(data);
      return settingsResponse.settings;
    } else {
      throw Exception('Failed to load settings: ${response.statusCode}');
    }
  }
}
