import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/appModels/bannersModel.dart';
import '../../models/appModels/servicesModel.dart';
import '../../models/appModels/operatorTypeCheckModel.dart';
import '../../models/appModels/newsModel.dart';
import '../../auth/httpClient.dart';

class AppRepository {
  Future<List<Banner>> fetchBanners() async {
    // Use public endpoint (no auth required)
    // Use SSL-aware client to handle certificate issues
    final client = AuthenticatedHttpClient.getSslAwareClient();
    try {
      final response = await client.get(
        Uri.parse('${AssetsConst.apiBase}api/android/banners/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bannersResponse = BannersResponse.fromJson(data);
        return bannersResponse.banners;
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<Settings> fetchSettings() async {
    final url = '${AssetsConst.apiBase}api/website-settings-android/';
    print('🔍 APP REPOSITORY: Fetching settings...');
    print('  URL: $url');
    
    // Try authenticated request first
    try {
      print('  📡 Attempting authenticated request...');
      final response = await AuthenticatedHttpClient.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        retryOn401: false, // Don't retry on 401
      );

      print('🔍 APP REPOSITORY: Settings API Response (Authenticated):');
      print('  Status Code: ${response.statusCode}');
      print('  Response Headers: ${response.headers}');
      print('  Response Body Length: ${response.body.length} bytes');
      print('  Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('  ✅ JSON parsed successfully');
        print('  JSON Data: $data');
        
        final settingsResponse = SettingsResponse.fromJson(data);
        print('  ✅ SettingsResponse created');
        print('  Settings: ${settingsResponse.settings}');
        print('  Logo: ${settingsResponse.settings.logo}');
        print('  Logo Image: ${settingsResponse.settings.logo?.image}');
        print('  App Logo: ${settingsResponse.settings.appLogo}');
        print('  App Logo Image: ${settingsResponse.settings.appLogo?.image}');
        
        return settingsResponse.settings;
      } else {
        final errorMsg = 'Failed to load settings: ${response.statusCode}';
        print('  ❌ Error: $errorMsg');
        print('  Response Body: ${response.body}');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('  ⚠️ Authenticated request failed: $e');
      print('  📡 Attempting unauthenticated request (public endpoint)...');
      
      // Fallback: Try unauthenticated request (for login page)
      // Use SSL-aware client to handle certificate issues
      try {
        final client = AuthenticatedHttpClient.getSslAwareClient();
        try {
          final response = await client.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 30));

          print('🔍 APP REPOSITORY: Settings API Response (Unauthenticated):');
          print('  Status Code: ${response.statusCode}');
          print('  Response Headers: ${response.headers}');
          print('  Response Body Length: ${response.body.length} bytes');
          print('  Response Body: ${response.body}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('  ✅ JSON parsed successfully (unauthenticated)');
            print('  JSON Data: $data');
            
            final settingsResponse = SettingsResponse.fromJson(data);
            print('  ✅ SettingsResponse created');
            print('  Settings: ${settingsResponse.settings}');
            print('  Logo: ${settingsResponse.settings.logo}');
            print('  Logo Image: ${settingsResponse.settings.logo?.image}');
            print('  App Logo: ${settingsResponse.settings.appLogo}');
            print('  App Logo Image: ${settingsResponse.settings.appLogo?.image}');
            
            return settingsResponse.settings;
          } else {
            final errorMsg = 'Failed to load settings (unauthenticated): ${response.statusCode}';
            print('  ❌ Error: $errorMsg');
            print('  Response Body: ${response.body}');
            throw Exception(errorMsg);
          }
        } finally {
          client.close();
        }
      } catch (e2, stackTrace) {
        print('  ❌ Unauthenticated request also failed: $e2');
        print('  Stack Trace: $stackTrace');
        rethrow;
      }
    }
  }

  Future<ServicesResponse> fetchServices() async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/android/services/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ServicesResponse.fromJson(data);
    } else {
      throw Exception('Failed to load services: ${response.statusCode}');
    }
  }

  Future<OperatorTypeCheckResponse> checkOperatorTypeApi(int operatorTypeId) async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/android/check-operator-type-api/?operator_type_id=$operatorTypeId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OperatorTypeCheckResponse.fromJson(data);
    } else {
      throw Exception('Failed to check operator type API: ${response.statusCode}');
    }
  }

  Future<NewsResponse> fetchNews() async {
    print('📰 [FETCH_NEWS] Starting news fetch...');
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/android/news/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('📰 [FETCH_NEWS] Response status: ${response.statusCode}');
    print('📰 [FETCH_NEWS] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📰 [FETCH_NEWS] Parsed data: $data');
      final newsResponse = NewsResponse.fromJson(data);
      print('📰 [FETCH_NEWS] NewsResponse created:');
      print('   - success: ${newsResponse.success}');
      print('   - hasNews: ${newsResponse.hasNews}');
      print('   - totalCount: ${newsResponse.totalCount}');
      print('   - userRole: ${newsResponse.userRole}');
      print('   - news items: ${newsResponse.news.length}');
      return newsResponse;
    } else if (response.statusCode == 401) {
      print('📰 [FETCH_NEWS] Authentication failed (401)');
      throw Exception('Authentication failed. Please login again.');
    } else {
      print('📰 [FETCH_NEWS] Failed with status: ${response.statusCode}');
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }
}
