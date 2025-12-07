class BannersResponse {
  final bool success;
  final List<Banner> banners;
  final int totalCount;

  BannersResponse({
    required this.success,
    required this.banners,
    required this.totalCount,
  });

  factory BannersResponse.fromJson(Map<String, dynamic> json) {
    return BannersResponse(
      success: json['success'] ?? false,
      banners: json['banners'] != null
          ? List<Banner>.from(json['banners'].map((x) => Banner.fromJson(x)))
          : [],
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class Banner {
  final int id;
  final String image;
  final String uploadedAt;

  Banner({required this.id, required this.image, required this.uploadedAt});

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}

class SettingsResponse {
  final bool success;
  final Settings settings;
  final int totalCount;

  SettingsResponse({
    required this.success,
    required this.settings,
    required this.totalCount,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      success: json['success'] ?? false,
      settings: Settings.fromJson(json['settings'] ?? {}),
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class Settings {
  final SettingItem? logo;
  final SettingItem? appLogo;

  Settings({this.logo, this.appLogo});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      logo: json['logo'] != null ? SettingItem.fromJson(json['logo']) : null,
      appLogo: json['app_logo'] != null
          ? SettingItem.fromJson(json['app_logo'])
          : null,
    );
  }
}

class SettingItem {
  final String settingType;
  final String image;
  final String uploadedAt;

  SettingItem({
    required this.settingType,
    required this.image,
    required this.uploadedAt,
  });

  factory SettingItem.fromJson(Map<String, dynamic> json) {
    return SettingItem(
      settingType: json['setting_type'] ?? '',
      image: json['image'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}
