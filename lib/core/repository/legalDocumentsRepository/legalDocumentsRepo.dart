import 'dart:convert';
import '../../const/assets_const.dart';
import '../../auth/httpClient.dart';

class LegalDocumentsRepository {
  /// Fetch legal documents (Terms & Conditions and Privacy Policy)
  /// This is a public API - no authentication required
  Future<LegalDocumentsResponse> fetchLegalDocuments() async {
    try {
      final url = Uri.parse('${AssetsConst.apiBase}api/android/legal-documents/');
      
      // Use SSL-aware client for unauthenticated requests
      final client = AuthenticatedHttpClient.getSslAwareClient();
      
      try {
        final response = await client.get(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));

        final data = json.decode(response.body);

        if (response.statusCode == 200) {
          return LegalDocumentsResponse.fromJson(data);
        } else {
          final errorMsg = data['error'] ?? 'Failed to fetch legal documents';
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('❌ [LEGAL_DOCUMENTS] Error fetching legal documents: $e');
      rethrow;
    }
  }
}

class LegalDocumentsResponse {
  final bool success;
  final LegalDocumentInfo termsConditions;
  final LegalDocumentInfo privacyPolicy;

  LegalDocumentsResponse({
    required this.success,
    required this.termsConditions,
    required this.privacyPolicy,
  });

  factory LegalDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return LegalDocumentsResponse(
      success: json['success'] ?? false,
      termsConditions: LegalDocumentInfo.fromJson(
        json['terms_conditions'] ?? {},
      ),
      privacyPolicy: LegalDocumentInfo.fromJson(
        json['privacy_policy'] ?? {},
      ),
    );
  }
}

class LegalDocumentInfo {
  final String? url;
  final bool enabled;

  LegalDocumentInfo({
    this.url,
    required this.enabled,
  });

  factory LegalDocumentInfo.fromJson(Map<String, dynamic> json) {
    return LegalDocumentInfo(
      url: json['url'],
      enabled: json['enabled'] ?? false,
    );
  }
}
