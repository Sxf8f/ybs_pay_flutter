class Service {
  final int id;
  final String name;
  final int operatorTypeId;
  final String? icon;
  final bool isActive;
  final int order;

  Service({
    required this.id,
    required this.name,
    required this.operatorTypeId,
    this.icon,
    required this.isActive,
    required this.order,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      operatorTypeId: json['operator_type_id'] ?? 0,
      icon: json['icon'],
      isActive: json['is_active'] ?? false,
      order: json['order'] ?? 999,
    );
  }
}

class ServicesResponse {
  final bool success;
  final List<Service> services;
  final int totalCount;

  ServicesResponse({
    required this.success,
    required this.services,
    required this.totalCount,
  });

  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    List<Service> servicesList = [];
    if (json['services'] != null && json['services'] is List) {
      servicesList = (json['services'] as List)
          .map((e) => Service.fromJson(e))
          .toList();
    }

    return ServicesResponse(
      success: json['success'] ?? false,
      services: servicesList,
      totalCount: json['total_count'] ?? 0,
    );
  }
}
