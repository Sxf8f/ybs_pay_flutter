import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../const/assets_const.dart';
import '../../models/userModels/userDetailsModel.dart';
import '../../models/userModels/profileModel.dart';
import '../../auth/httpClient.dart';
import '../../auth/tokenManager.dart';

class UserRepository {
  Future<UserDetails> fetchUserDetails() async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/user-details-android/'),
      headers: {
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

  /// Get profile data for editing
  Future<ProfileGetResponse> getProfileForEditing() async {
    final response = await AuthenticatedHttpClient.get(
      Uri.parse('${AssetsConst.apiBase}api/android/profile/get/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ProfileGetResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to fetch profile data';
      throw Exception(errorMsg);
    }
  }

  /// Update profile (text fields only)
  Future<ProfileUpdateResponse> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String pincode,
    required String address,
    required String outlet,
    required bool isGst,
  }) async {
    final body = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'pincode': pincode,
      'address': address,
      'outlet': outlet,
      'is_gst': isGst,
    };

    final response = await AuthenticatedHttpClient.put(
      Uri.parse('${AssetsConst.apiBase}api/android/profile/update/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ProfileUpdateResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to update profile';
      throw Exception(errorMsg);
    }
  }

  /// Update profile with profile picture
  Future<ProfileUpdateResponse> updateProfileWithPicture({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String pincode,
    required String address,
    required String outlet,
    required bool isGst,
    required File profilePicture,
  }) async {
    // Get valid token (will auto-refresh if needed)
    final token = await TokenManager.getValidToken();
    if (token == null) {
      throw Exception('No valid token available. Please login again.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AssetsConst.apiBase}api/android/profile/update/'),
    );

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['email'] = email;
    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['phone_number'] = phoneNumber;
    request.fields['pincode'] = pincode;
    request.fields['address'] = address;
    request.fields['outlet'] = outlet;
    request.fields['is_gst'] = isGst.toString();

    // Add profile picture
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture',
        profilePicture.path,
      ),
    );

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ProfileUpdateResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to update profile';
      throw Exception(errorMsg);
    }
  }

  /// Upload profile picture only
  Future<ProfilePictureUploadResponse> uploadProfilePicture(File profilePicture) async {
    // Get valid token (will auto-refresh if needed)
    final token = await AuthenticatedHttpClient.getToken();
    if (token == null) {
      throw Exception('No valid token available. Please login again.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AssetsConst.apiBase}api/android/profile/picture/upload/'),
    );

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add profile picture
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture',
        profilePicture.path,
      ),
    );

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ProfilePictureUploadResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      final errorMsg = data['error'] ?? 
                      data['detail'] ?? 
                      data['message'] ?? 
                      'Failed to upload profile picture';
      throw Exception(errorMsg);
    }
  }
}
