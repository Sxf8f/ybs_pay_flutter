import 'dart:convert';
import '../../const/assets_const.dart';
import '../../models/popupModels/popupModel.dart';
import '../../auth/httpClient.dart';

class PopupRepository {
  /// Check if there's a popup to display
  Future<PopupCheckResponse> checkPopup() async {
    try {
      final url = Uri.parse('${AssetsConst.apiBase}api/android/popup/check/');
      
      final response = await AuthenticatedHttpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return PopupCheckResponse.fromJson(data);
      } else {
        final errorMsg = data['error'] ?? 
                        data['detail'] ?? 
                        data['message'] ?? 
                        'Failed to check popup';
        throw Exception(errorMsg);
      }
    } catch (e) {
      // If token is missing or API fails, return no popup
      if (e.toString().contains('No valid token')) {
        return PopupCheckResponse(
          success: false,
          hasPopup: false,
          message: 'Not authenticated',
        );
      }
      rethrow;
    }
  }

  /// Mark popup as seen (for one_time popups)
  Future<MarkSeenResponse> markPopupAsSeen(int popupId) async {
    final body = {
      'popup_id': popupId,
    };

    final url = Uri.parse('${AssetsConst.apiBase}api/android/popup/mark-seen/');
    
    final response = await AuthenticatedHttpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return MarkSeenResponse.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to mark popup as seen';
      throw Exception(errorMsg);
    }
  }
}
