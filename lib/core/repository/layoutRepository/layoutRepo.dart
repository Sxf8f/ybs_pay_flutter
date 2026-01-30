// lib/repositories/layout_repository.dart
import 'dart:convert';
import 'package:ybs_pay/core/const/assets_const.dart';
import '../../models/authModels/userModel.dart';
import '../../auth/httpClient.dart';

class LayoutRepository {
  // Try multiple possible endpoint paths
  final List<String> possibleEndpoints = [
    "${AssetsConst.apiBase}api/layout-settings/all/",
    "${AssetsConst.apiBase}api/android/layout-settings/all/",
    "${AssetsConst.apiBase}api/layout-settings/",
    "${AssetsConst.apiBase}layout-settings/api/all/", // Original
    "${AssetsConst.apiBase}api/recharge-layouts/",
    "${AssetsConst.apiBase}api/android/recharge-layouts/",
  ];
  
  final String apiUrl = "${AssetsConst.apiBase}api/layout-settings/all/"; // Try most likely first

  Future<List<LayoutModel>> fetchLayouts() async {
    print('🔍 LAYOUT REPOSITORY: Fetching layouts...');
    print('   📡 Trying endpoint: $apiUrl');
    
    // Try the primary endpoint first
    Exception? lastException;
    
    for (int i = 0; i < possibleEndpoints.length; i++) {
      final endpoint = possibleEndpoints[i];
      print('   🔄 Attempt ${i + 1}/${possibleEndpoints.length}: $endpoint');
      
      try {
        final response = await AuthenticatedHttpClient.get(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      
        print('   📊 Status Code: ${response.statusCode}');
        print('   📋 Content-Type: ${response.headers['content-type'] ?? 'not set'}');
        print('   📏 Response Body Length: ${response.body.length} bytes');
        
        // Print first 500 characters of response to see if it's HTML or JSON
        final preview = response.body.length > 500 
            ? '${response.body.substring(0, 500)}...' 
            : response.body;
        print('   📄 Response Body Preview (first 500 chars):');
        print('   ┌─────────────────────────────────────────────────────────');
        print('   │ $preview');
        print('   └─────────────────────────────────────────────────────────');
        
        // Check if response is HTML (common error page indicator)
        final isHtml = response.body.trim().startsWith('<!DOCTYPE') || 
            response.body.trim().startsWith('<html') ||
            response.body.trim().startsWith('<!doctype');
        
        if (isHtml) {
          print('   ⚠️  WARNING: Response appears to be HTML, not JSON!');
          print('   ❌ This endpoint returned HTML - trying next endpoint...');
          lastException = Exception(
            'Server returned HTML instead of JSON. Status: ${response.statusCode}. '
            'Endpoint: $endpoint'
          );
          continue; // Try next endpoint
        }
        
        if (response.statusCode == 200) {
          print('   ✅ Status 200 - Attempting to parse JSON...');
          try {
            final decoded = json.decode(response.body);
            print('   ✅ JSON parsed successfully!');
            
            // Check for different possible response structures
            List<dynamic>? layoutsList;
            dynamic data;
            
            if (decoded is List) {
              // Response is directly a list
              layoutsList = decoded;
              print('   📦 Response is a direct list with ${layoutsList.length} items');
            } else if (decoded is Map) {
              data = decoded;
              print('   📦 Data keys: ${data.keys.toList()}');
              
              if (data.containsKey('layouts')) {
                layoutsList = data['layouts'];
              } else if (data.containsKey('data') && data['data'] is List) {
                layoutsList = data['data'];
              } else if (data.containsKey('results')) {
                layoutsList = data['results'];
              }
            } else {
              print('   ⚠️  Unexpected response type: ${decoded.runtimeType}');
              lastException = Exception('Unexpected response type: ${decoded.runtimeType}');
              continue;
            }
            
            if (layoutsList != null) {
              print('   📋 Layouts found: ${layoutsList.length}');
              
              if (layoutsList.isNotEmpty) {
                print('   📝 First layout preview:');
                final firstLayoutStr = jsonEncode(layoutsList[0]);
                print('      ${firstLayoutStr.length > 200 ? firstLayoutStr.substring(0, 200) + '...' : firstLayoutStr}');
              }
              
              final layouts = layoutsList
                  .map((e) => LayoutModel.fromJson(e))
                  .toList();
              print('   ✅ SUCCESS! Created ${layouts.length} LayoutModel objects from endpoint: $endpoint');
              return layouts;
            } else {
              print('   ⚠️  WARNING: Response does not contain layouts in expected format');
              if (data != null && data is Map) {
                print('   📦 Available keys: ${data.keys.toList()}');
                print('   📄 Full response: ${jsonEncode(data)}');
                lastException = Exception(
                  'Response does not contain layouts. Available keys: ${data.keys.toList()}'
                );
              } else {
                print('   📄 Full response: ${jsonEncode(decoded)}');
                lastException = Exception('Response does not contain layouts in expected format');
              }
              continue; // Try next endpoint
            }
          } catch (e) {
            print('   ❌ JSON Parse Error: $e');
            print('   📄 Full response body:');
            print('   ┌─────────────────────────────────────────────────────────');
            print('   │ ${response.body}');
            print('   └─────────────────────────────────────────────────────────');
            lastException = e is Exception ? e : Exception(e.toString());
            continue; // Try next endpoint
          }
        } else {
          print('   ❌ Non-200 status code: ${response.statusCode}');
          lastException = Exception(
            "Status: ${response.statusCode} for endpoint: $endpoint"
          );
          continue; // Try next endpoint
        }
      } catch (e) {
        print('   ❌ Request failed: $e');
        lastException = e is Exception ? e : Exception(e.toString());
        continue; // Try next endpoint
      }
    }
    
    // If we get here, all endpoints failed
    print('   ❌ ALL ENDPOINTS FAILED!');
    print('   📋 Tried endpoints:');
    for (int i = 0; i < possibleEndpoints.length; i++) {
      print('      ${i + 1}. ${possibleEndpoints[i]}');
    }
    throw lastException ?? Exception('All endpoint attempts failed. Check backend API routes.');
  }
}
