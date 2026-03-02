class CategoryTypeModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? color;
  final bool requiresPrescription;
  final bool isNarcotic;
  final int categoriesCount;

  CategoryTypeModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.color,
    this.requiresPrescription = false,
    this.isNarcotic = false,
    this.categoriesCount = 0,
  });

  factory CategoryTypeModel.fromJson(Map<String, dynamic> json) {
    return CategoryTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      color: json['color'],
      requiresPrescription: json['requires_prescription'] ?? false,
      isNarcotic: json['is_narcotic'] ?? false,
      categoriesCount: json['categories_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'description': description,
        'color': color,
        'requires_prescription': requiresPrescription,
        'is_narcotic': isNarcotic,
        'categories_count': categoriesCount,
      };

  // Special "All" category type for filtering
  static CategoryTypeModel all() => CategoryTypeModel(
        id: 0,
        name: 'Semua',
        code: 'all',
        categoriesCount: 0,
      );
}

/// Compact CategoryType info embedded in Category or Product responses
class CategoryTypeInfo {
  final int id;
  final String name;
  final String code;
  final String? color;
  final bool requiresPrescription;
  final bool isNarcotic;

  CategoryTypeInfo({
    required this.id,
    required this.name,
    required this.code,
    this.color,
    this.requiresPrescription = false,
    this.isNarcotic = false,
  });

  factory CategoryTypeInfo.fromJson(Map<String, dynamic> json) {
    return CategoryTypeInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      color: json['color'],
      requiresPrescription: json['requires_prescription'] ?? false,
      isNarcotic: json['is_narcotic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'color': color,
        'requires_prescription': requiresPrescription,
        'is_narcotic': isNarcotic,
      };
}
