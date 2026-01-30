class UserListResponse {
  final bool success;
  final int count;
  final int returnedCount;
  final List<DistributorUserItem> users;
  final UserListFilters filters;

  UserListResponse({
    required this.success,
    required this.count,
    required this.returnedCount,
    required this.users,
    required this.filters,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      users: (json['data'] as List<dynamic>?)
              ?.map((e) => DistributorUserItem.fromJson(e))
              .toList() ??
          (json['users'] as List<dynamic>?)
              ?.map((e) => DistributorUserItem.fromJson(e))
              .toList() ??
          [],
      filters: UserListFilters.fromJson(json['filters'] ?? {}),
    );
  }
}

class DistributorUserItem {
  final int id;
  final String username;
  final String email;
  final String phoneNumber;
  final double balance;
  final UserRole role;
  final UserSlab slab;
  final bool isActive;
  final String? outlet;
  final String? outletDisplay;
  final String? joinDate;
  final String? joinBy;
  final String? joinMobile;
  final String? createdAt;

  DistributorUserItem({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.balance,
    required this.role,
    required this.slab,
    required this.isActive,
    this.outlet,
    this.outletDisplay,
    this.joinDate,
    this.joinBy,
    this.joinMobile,
    this.createdAt,
  });

  factory DistributorUserItem.fromJson(Map<String, dynamic> json) {
    return DistributorUserItem(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      balance: (json['balance'] is int)
          ? (json['balance'] as int).toDouble()
          : (json['balance'] is double)
              ? json['balance']
              : double.tryParse(json['balance'].toString()) ?? 0.0,
      role: UserRole.fromJson(json['role'] ?? {}),
      slab: UserSlab.fromJson(json['slab'] ?? {}),
      isActive: json['is_active'] ?? false,
      outlet: json['outlet'],
      outletDisplay: json['outlet_display'],
      joinDate: json['join_date'],
      joinBy: json['join_by'],
      joinMobile: json['join_mobile'],
      createdAt: json['created_at'],
    );
  }
}

class UserRole {
  final int id;
  final String name;
  final String? code;

  UserRole({required this.id, required this.name, this.code});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
    );
  }
}

class UserSlab {
  final int slabID;
  final String slabName;

  UserSlab({required this.slabID, required this.slabName});

  factory UserSlab.fromJson(Map<String, dynamic> json) {
    return UserSlab(
      slabID: json['slabID'] ?? 0,
      slabName: json['slabName'] ?? '',
    );
  }
}

class UserListFilters {
  final List<UserRole> roles;
  final List<UserSlab> slabs;
  final List<CriteriaChoice> criteriaChoices;

  UserListFilters({
    required this.roles,
    required this.slabs,
    required this.criteriaChoices,
  });

  factory UserListFilters.fromJson(Map<String, dynamic> json) {
    return UserListFilters(
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => UserRole.fromJson(e))
              .toList() ??
          [],
      slabs: (json['slabs'] as List<dynamic>?)
              ?.map((e) => UserSlab.fromJson(e))
              .toList() ??
          [],
      criteriaChoices: (json['criteria_choices'] as List<dynamic>?)
              ?.map((e) => CriteriaChoice.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CriteriaChoice {
  final String value;
  final String display;

  CriteriaChoice({required this.value, required this.display});

  factory CriteriaChoice.fromJson(Map<String, dynamic> json) {
    return CriteriaChoice(
      value: json['value'] ?? '',
      display: json['display'] ?? '',
    );
  }
}

class CreateUserResponse {
  final bool success;
  final String message;
  final CreatedUser data;

  CreateUserResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CreatedUser.fromJson(json['data'] ?? json['user'] ?? {}),
    );
  }
}

class CreatedUser {
  final int id;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;
  final String? secureKey;
  final String? otp;

  CreatedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.secureKey,
    this.otp,
  });

  factory CreatedUser.fromJson(Map<String, dynamic> json) {
    return CreatedUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      password: json['password'],
      secureKey: json['secure_key'],
      otp: json['otp'],
    );
  }
}

