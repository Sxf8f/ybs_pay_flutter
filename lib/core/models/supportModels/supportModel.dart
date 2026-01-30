class SupportInfoResponse {
  final bool success;
  final SupportData data;
  final String? message;

  SupportInfoResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory SupportInfoResponse.fromJson(Map<String, dynamic> json) {
    return SupportInfoResponse(
      success: json['success'] ?? false,
      data: SupportData.fromJson(json['data'] ?? {}),
      message: json['message'],
    );
  }
}

class SupportData {
  final ContactInfo customerCare;
  final ContactInfo accountsFinance;
  final SocialMediaInfo socialMedia;
  final WebsiteInfo website;
  final AddressInfo address;
  final TollFreeInfo tollFree;
  final BankDetails bankDetails;
  final LegalInfo legal;

  SupportData({
    required this.customerCare,
    required this.accountsFinance,
    required this.socialMedia,
    required this.website,
    required this.address,
    required this.tollFree,
    required this.bankDetails,
    required this.legal,
  });

  factory SupportData.fromJson(Map<String, dynamic> json) {
    return SupportData(
      customerCare: ContactInfo.fromJson(json['customer_care'] ?? {}),
      accountsFinance: ContactInfo.fromJson(json['accounts_finance'] ?? {}),
      socialMedia: SocialMediaInfo.fromJson(json['social_media'] ?? {}),
      website: WebsiteInfo.fromJson(json['website'] ?? {}),
      address: AddressInfo.fromJson(json['address'] ?? {}),
      tollFree: TollFreeInfo.fromJson(json['toll_free'] ?? {}),
      bankDetails: BankDetails.fromJson(json['bank_details'] ?? {}),
      legal: LegalInfo.fromJson(json['legal'] ?? {}),
    );
  }
}

class ContactInfo {
  final String mobile;
  final String phone;
  final String whatsapp;

  ContactInfo({
    required this.mobile,
    required this.phone,
    required this.whatsapp,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      mobile: json['mobile'] ?? '',
      phone: json['phone'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
    );
  }
}

class SocialMediaInfo {
  final SocialMediaItem facebook;
  final SocialMediaItem instagram;
  final SocialMediaItem twitterX;

  SocialMediaInfo({
    required this.facebook,
    required this.instagram,
    required this.twitterX,
  });

  factory SocialMediaInfo.fromJson(Map<String, dynamic> json) {
    return SocialMediaInfo(
      facebook: SocialMediaItem.fromJson(json['facebook'] ?? {}),
      instagram: SocialMediaItem.fromJson(json['instagram'] ?? {}),
      twitterX: SocialMediaItem.fromJson(json['twitter_x'] ?? {}),
    );
  }
}

class SocialMediaItem {
  final String url;
  final bool enabled;

  SocialMediaItem({
    required this.url,
    required this.enabled,
  });

  factory SocialMediaItem.fromJson(Map<String, dynamic> json) {
    return SocialMediaItem(
      url: json['url'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }
}

class WebsiteInfo {
  final String url;
  final bool enabled;

  WebsiteInfo({
    required this.url,
    required this.enabled,
  });

  factory WebsiteInfo.fromJson(Map<String, dynamic> json) {
    return WebsiteInfo(
      url: json['url'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }
}

class AddressInfo {
  final String fullAddress;
  final bool enabled;

  AddressInfo({
    required this.fullAddress,
    required this.enabled,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      fullAddress: json['full_address'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }
}

class TollFreeInfo {
  final List<TollFreeNumber> mobile;
  final List<TollFreeNumber> dth;

  TollFreeInfo({
    required this.mobile,
    required this.dth,
  });

  factory TollFreeInfo.fromJson(Map<String, dynamic> json) {
    return TollFreeInfo(
      mobile: json['mobile'] != null
          ? List<TollFreeNumber>.from(
              json['mobile'].map((x) => TollFreeNumber.fromJson(x)),
            )
          : [],
      dth: json['dth'] != null
          ? List<TollFreeNumber>.from(
              json['dth'].map((x) => TollFreeNumber.fromJson(x)),
            )
          : [],
    );
  }
}

class TollFreeNumber {
  final String operatorName;
  final String phoneNumber;
  final bool enabled;

  TollFreeNumber({
    required this.operatorName,
    required this.phoneNumber,
    required this.enabled,
  });

  factory TollFreeNumber.fromJson(Map<String, dynamic> json) {
    return TollFreeNumber(
      operatorName: json['operator_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }
}

class BankDetails {
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String branch;
  final String branchAddress;
  final bool enabled;

  BankDetails({
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branch,
    required this.branchAddress,
    required this.enabled,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bank_name'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      branch: json['branch'] ?? '',
      branchAddress: json['branch_address'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }
}

class LegalInfo {
  final LegalDocument privacyPolicy;
  final LegalDocument termsConditions;

  LegalInfo({
    required this.privacyPolicy,
    required this.termsConditions,
  });

  factory LegalInfo.fromJson(Map<String, dynamic> json) {
    return LegalInfo(
      privacyPolicy: LegalDocument.fromJson(json['privacy_policy'] ?? {}),
      termsConditions: LegalDocument.fromJson(json['terms_conditions'] ?? {}),
    );
  }
}

class LegalDocument {
  final String url;
  final bool enabled;

  LegalDocument({
    required this.url,
    required this.enabled,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      url: json['url'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }
}

