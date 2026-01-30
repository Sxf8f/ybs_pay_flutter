import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/dashboardModels/dashboardModel.dart';
import '../../auth/httpClient.dart';

class DashboardRepository {
  /// Fetch dashboard statistics
  Future<DashboardStatisticsResponse> fetchStatistics({
    String? startDate,
    String? endDate,
    String? period,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (period != null) queryParams['period'] = period;

    final uri = Uri.parse('${AssetsConst.apiBase}api/android/dashboard/statistics/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await AuthenticatedHttpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return DashboardStatisticsResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch dashboard statistics';
      throw Exception(errorMsg);
    }
  }
}
