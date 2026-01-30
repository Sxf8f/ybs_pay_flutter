import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/supportModels/supportModel.dart';
import '../../auth/httpClient.dart';

class SupportRepository {
  Future<SupportInfoResponse> getSupportInfo() async {
    try {
      final url = Uri.parse('${AssetsConst.apiBase}api/android/support/');

      final response = await AuthenticatedHttpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Support API Response Status: ${response.statusCode}');
      print('Support API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Support API Data Decoded: $data');
          return SupportInfoResponse.fromJson(data);
        } catch (e) {
          print('Error parsing support response: $e');
          throw Exception('Failed to parse support information: $e');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Support API endpoint not found. Please contact backend team.');
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(
            errorData['error'] ?? 
            errorData['message'] ?? 
            'Failed to fetch support information (Status: ${response.statusCode})',
          );
        } catch (e) {
          throw Exception(
            'Failed to fetch support information (Status: ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      print('Support Repository Error: $e');
      print('Error Type: ${e.runtimeType}');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Unexpected error: $e');
      }
    }
  }
}
