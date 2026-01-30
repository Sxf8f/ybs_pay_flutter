import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/authModels/userModel.dart';
import '../../auth/httpClient.dart';

class OperatorFormConfigRepository {
  Future<LayoutModel> fetchOperatorFormConfig(int operatorId) async {
    final url = Uri.parse(
      '${AssetsConst.apiBase}api/android/operator-form-config/?operator_id=$operatorId'
    );
    
    print('🔍 OPERATOR FORM CONFIG REPOSITORY: Fetching config for operator $operatorId...');
    print('   📡 URL: $url');
    
    final response = await AuthenticatedHttpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    print('   📊 Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('   ✅ JSON parsed successfully');
      
      // Debug: Print raw amount and bill_fetch_mode from API
      if (data is Map) {
        print('   💰 Raw API Amount Config:');
        if (data.containsKey('amount')) {
          print('      - amount: ${data['amount']}');
        }
        print('   📋 Raw API Bill Fetch Settings:');
        print('      - bill_fetch_mode: "${data['bill_fetch_mode']}" (type: ${data['bill_fetch_mode']?.runtimeType})');
        print('      - require_bill_fetch_first: ${data['require_bill_fetch_first']}');
        print('      - amount_editable_after_fetch: ${data['amount_editable_after_fetch']}');
        print('   🔘 Raw API Fetch Bill Button Settings:');
        print('      - fetch_bill_button: ${data['fetch_bill_button']} (type: ${data['fetch_bill_button']?.runtimeType})');
        print('      - fetch_bill_endpoint: "${data['fetch_bill_endpoint']}" (empty: ${data['fetch_bill_endpoint']?.toString().isEmpty ?? true})');
        print('   📋 Full API Response Keys: ${data.keys.toList()}');
        // Print full response for debugging
        print('   📄 Full API Response: ${jsonEncode(data)}');
      }
      
      // Handle both direct LayoutModel format and wrapped format
      if (data is Map<String, dynamic>) {
        // If response has 'success' wrapper, extract the layout data
        if (data.containsKey('success') && data.containsKey('data')) {
          final layoutData = data['data'];
          if (layoutData is Map<String, dynamic>) {
            return LayoutModel.fromJson(layoutData);
          } else if (layoutData is Map) {
            return LayoutModel.fromJson(Map<String, dynamic>.from(layoutData));
          }
        } else if (data.containsKey('operator_id')) {
          // Direct LayoutModel format
          return LayoutModel.fromJson(data);
        }
      } else if (data is Map) {
        // Fallback for Map<dynamic, dynamic>
        return LayoutModel.fromJson(Map<String, dynamic>.from(data));
      }
      
      // Default: try to convert to Map<String, dynamic>
      if (data is Map) {
        return LayoutModel.fromJson(Map<String, dynamic>.from(data));
      }
      
      throw Exception('Invalid response format: expected Map');
    } else {
      print('   ❌ Error: Status ${response.statusCode}');
      print('   Response: ${response.body}');
      throw Exception('Failed to fetch operator form config: ${response.statusCode}');
    }
  }
}
