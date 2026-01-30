class ProfileData {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String pincode;
  final String address;
  final String outlet;
  final bool isGst;
  final String? profilePictureUrl;
  final String roleName;
  final String roleCode;

  ProfileData({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.pincode,
    required this.address,
    required this.outlet,
    required this.isGst,
    this.profilePictureUrl,
    required this.roleName,
    required this.roleCode,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      pincode: json['pincode'] ?? '',
      address: json['address'] ?? '',
      outlet: json['outlet'] ?? '',
      isGst: json['is_gst'] ?? false,
      profilePictureUrl: json['profile_picture_url'],
      roleName: json['role_name'] ?? '',
      roleCode: json['role_code'] ?? '',
    );
  }
}

class ProfileGetResponse {
  final bool success;
  final ProfileData profile;

  ProfileGetResponse({
    required this.success,
    required this.profile,
  });

  factory ProfileGetResponse.fromJson(Map<String, dynamic> json) {
    return ProfileGetResponse(
      success: json['success'] ?? false,
      profile: ProfileData.fromJson(json['profile'] ?? {}),
    );
  }
}

class ProfileUpdateResponse {
  final bool success;
  final String message;
  final UserProfileData user;

  ProfileUpdateResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: UserProfileData.fromJson(json['user'] ?? {}),
    );
  }
}

class UserProfileData {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String pincode;
  final String address;
  final String outlet;
  final bool isGst;
  final String? profilePictureUrl;
  final String balance;
  final String roleName;
  final String roleCode;
  final String? slabName;
  final int? slabId;
  final String? commissionRate;
  final String? loginId;
  final String createdAt;
  final String updatedAt;
  final bool forcePasswordChange;
  final String? liveid;

  UserProfileData({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.pincode,
    required this.address,
    required this.outlet,
    required this.isGst,
    this.profilePictureUrl,
    required this.balance,
    required this.roleName,
    required this.roleCode,
    this.slabName,
    this.slabId,
    this.commissionRate,
    this.loginId,
    required this.createdAt,
    required this.updatedAt,
    required this.forcePasswordChange,
    this.liveid,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      pincode: json['pincode'] ?? '',
      address: json['address'] ?? '',
      outlet: json['outlet'] ?? '',
      isGst: json['is_gst'] ?? false,
      profilePictureUrl: json['profile_picture_url'],
      balance: json['balance']?.toString() ?? '0.00',
      roleName: json['role_name'] ?? '',
      roleCode: json['role_code'] ?? '',
      slabName: json['slab_name'],
      slabId: json['slab_id'],
      commissionRate: json['commission_rate']?.toString(),
      loginId: json['login_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      forcePasswordChange: json['force_password_change'] ?? false,
      liveid: json['liveid'],
    );
  }
}

class ProfilePictureUploadResponse {
  final bool success;
  final String message;
  final String profilePictureUrl;

  ProfilePictureUploadResponse({
    required this.success,
    required this.message,
    required this.profilePictureUrl,
  });

  factory ProfilePictureUploadResponse.fromJson(Map<String, dynamic> json) {
    return ProfilePictureUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }
}

