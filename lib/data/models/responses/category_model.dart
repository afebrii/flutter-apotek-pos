import 'category_type_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? type; // Legacy enum value
  final CategoryTypeInfo? categoryType;
  final bool requiresPrescription;
  final bool isNarcotic;
  final int productsCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.categoryType,
    this.requiresPrescription = false,
    this.isNarcotic = false,
    this.productsCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'],
      categoryType: json['category_type'] != null
          ? CategoryTypeInfo.fromJson(json['category_type'])
          : null,
      requiresPrescription: json['requires_prescription'] ?? false,
      isNarcotic: json['is_narcotic'] ?? false,
      productsCount: json['products_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type,
        'category_type': categoryType?.toJson(),
        'requires_prescription': requiresPrescription,
        'is_narcotic': isNarcotic,
        'products_count': productsCount,
      };

  // Special "All" category for filtering
  static CategoryModel all() => CategoryModel(
        id: 0,
        name: 'Semua',
        productsCount: 0,
      );

  /// Get display color from category type, or default gray
  String get displayColor => categoryType?.color ?? '#6b7280';

  /// Get display type name from category type
  String? get displayTypeName => categoryType?.name ?? type;
}
