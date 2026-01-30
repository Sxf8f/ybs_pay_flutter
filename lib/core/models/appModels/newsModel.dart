class NewsResponse {
  final bool success;
  final List<NewsItem> news;
  final int totalCount;
  final String userRole;
  final bool hasNews;

  NewsResponse({
    required this.success,
    required this.news,
    required this.totalCount,
    required this.userRole,
    required this.hasNews,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      success: json['success'] ?? false,
      news: json['news'] != null
          ? List<NewsItem>.from(json['news'].map((x) => NewsItem.fromJson(x)))
          : [],
      totalCount: json['total_count'] ?? 0,
      userRole: json['user_role'] ?? '',
      hasNews: json['has_news'] ?? false,
    );
  }
}

class NewsItem {
  final int id;
  final String title;
  final String content;
  final String? createdAt;
  final List<String> userTypes;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
    required this.userTypes,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'],
      userTypes: json['user_types'] != null
          ? List<String>.from(json['user_types'])
          : [],
    );
  }
}
