class UserDetailsResponse {
  final bool success;
  final UserDetails user;

  UserDetailsResponse({required this.success, required this.user});

  factory UserDetailsResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailsResponse(
      success: json['success'] ?? false,
      user: UserDetails.fromJson(json['user'] ?? {}),
    );
  }
}

class UserDetails {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String pincode;
  final String address;
  final String outlet;
  final String balance;
  final String roleName;
  final String roleCode;
  final int? roleId;
  final String slabName;
  final int slabId;
  final bool isGst;
  final double? commissionRate;
  final String? loginId;
  final String createdAt;
  final String updatedAt;
  final bool forcePasswordChange;
  final String? liveid;
  final String? profilePictureUrl;

  UserDetails({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.pincode,
    required this.address,
    required this.outlet,
    required this.balance,
    required this.roleName,
    required this.roleCode,
    this.roleId,
    required this.slabName,
    required this.slabId,
    required this.isGst,
    this.commissionRate,
    this.loginId,
    required this.createdAt,
    required this.updatedAt,
    required this.forcePasswordChange,
    this.liveid,
    this.profilePictureUrl,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      pincode: json['pincode'] ?? '',
      address: json['address'] ?? '',
      outlet: json['outlet'] ?? '',
      balance: json['balance'] ?? '0.00',
      roleName: json['role_name'] ?? '',
      roleCode: json['role_code'] ?? '',
      roleId: json['role_id'] ?? json['roleId'],
      slabName: json['slab_name'] ?? '',
      slabId: json['slab_id'] ?? 0,
      isGst: json['is_gst'] ?? false,
      commissionRate: json['commission_rate'] != null
          ? double.tryParse(json['commission_rate'].toString())
          : null,
      loginId: json['login_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      forcePasswordChange: json['force_password_change'] ?? false,
      liveid: json['liveid'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  String get fullName {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '${firstName} ${lastName}'.trim();
    }
    return username;
  }
}
