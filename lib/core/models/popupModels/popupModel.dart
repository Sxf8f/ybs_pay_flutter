class PopupCheckResponse {
  final bool success;
  final bool hasPopup;
  final Popup? popup;
  final String? message;

  PopupCheckResponse({
    required this.success,
    required this.hasPopup,
    this.popup,
    this.message,
  });

  factory PopupCheckResponse.fromJson(Map<String, dynamic> json) {
    return PopupCheckResponse(
      success: json['success'] ?? false,
      hasPopup: json['has_popup'] ?? false,
      popup: json['popup'] != null ? Popup.fromJson(json['popup']) : null,
      message: json['message'],
    );
  }
}

class Popup {
  final int id;
  final String type; // "every_time" or "one_time"
  final String title;
  final String content;
  final String? imageUrl;
  final String? backgroundImageUrl;
  final String backgroundColor;
  final String textColor;
  final String titleColor;
  final String buttonText;
  final String buttonColor;
  final String buttonTextColor;
  final int buttonBorderRadius;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  final int priority;
  final String createdAt;
  final String updatedAt;

  Popup({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.imageUrl,
    this.backgroundImageUrl,
    required this.backgroundColor,
    required this.textColor,
    required this.titleColor,
    required this.buttonText,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.buttonBorderRadius,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Popup.fromJson(Map<String, dynamic> json) {
    return Popup(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'every_time',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      backgroundImageUrl: json['background_image_url'],
      backgroundColor: json['background_color'] ?? '#FFFFFF',
      textColor: json['text_color'] ?? '#000000',
      titleColor: json['title_color'] ?? '#1A1A1A',
      buttonText: json['button_text'] ?? 'OK',
      buttonColor: json['button_color'] ?? '#007AFF',
      buttonTextColor: json['button_text_color'] ?? '#FFFFFF',
      buttonBorderRadius: json['button_border_radius'] ?? 8,
      isActive: json['is_active'] ?? true,
      startDate: json['start_date'],
      endDate: json['end_date'],
      priority: json['priority'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  bool get isOneTime => type == 'one_time';
  bool get isEveryTime => type == 'every_time';
}

class MarkSeenResponse {
  final bool success;
  final String message;
  final int popupId;
  final int userId;
  final String viewedAt;

  MarkSeenResponse({
    required this.success,
    required this.message,
    required this.popupId,
    required this.userId,
    required this.viewedAt,
  });

  factory MarkSeenResponse.fromJson(Map<String, dynamic> json) {
    return MarkSeenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      popupId: json['popup_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      viewedAt: json['viewed_at'] ?? '',
    );
  }
}

