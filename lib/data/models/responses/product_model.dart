class ProductModel {
  final int id;
  final String code;
  final String? barcode;
  final String? kfaCode;
  final String name;
  final String? genericName;
  final String? description;
  final String? image;
  final CategoryInfo? category;
  final UnitInfo? baseUnit;
  final String purchasePrice;
  final String sellingPrice;
  final int totalStock;
  final int minStock;
  final int? maxStock;
  final String? rackLocation;
  final bool requiresPrescription;
  final bool isActive;
  final bool isLowStock;
  final List<BatchModel> batches;
  final List<UnitConversionModel> unitConversions;

  ProductModel({
    required this.id,
    required this.code,
    this.barcode,
    this.kfaCode,
    required this.name,
    this.genericName,
    this.description,
    this.image,
    this.category,
    this.baseUnit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.totalStock,
    this.minStock = 0,
    this.maxStock,
    this.rackLocation,
    this.requiresPrescription = false,
    this.isActive = true,
    this.isLowStock = false,
    this.batches = const [],
    this.unitConversions = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      barcode: json['barcode'],
      kfaCode: json['kfa_code'],
      name: json['name'] ?? '',
      genericName: json['generic_name'],
      description: json['description'],
      image: json['image'],
      category: json['category'] != null
          ? CategoryInfo.fromJson(json['category'])
          : null,
      baseUnit:
          json['base_unit'] != null ? UnitInfo.fromJson(json['base_unit']) : null,
      purchasePrice: json['purchase_price']?.toString() ?? '0',
      sellingPrice: json['selling_price']?.toString() ?? '0',
      totalStock: json['total_stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      maxStock: json['max_stock'],
      rackLocation: json['rack_location'],
      requiresPrescription: json['requires_prescription'] ?? false,
      isActive: json['is_active'] ?? true,
      isLowStock: json['is_low_stock'] ?? false,
      batches: json['batches'] != null
          ? (json['batches'] as List)
              .map((e) => BatchModel.fromJson(e))
              .toList()
          : [],
      unitConversions: json['unit_conversions'] != null
          ? (json['unit_conversions'] as List)
              .map((e) => UnitConversionModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'barcode': barcode,
        'kfa_code': kfaCode,
        'name': name,
        'generic_name': genericName,
        'description': description,
        'image': image,
        'category': category?.toJson(),
        'base_unit': baseUnit?.toJson(),
        'purchase_price': purchasePrice,
        'selling_price': sellingPrice,
        'total_stock': totalStock,
        'min_stock': minStock,
        'max_stock': maxStock,
        'rack_location': rackLocation,
        'requires_prescription': requiresPrescription,
        'is_active': isActive,
        'is_low_stock': isLowStock,
        'batches': batches.map((e) => e.toJson()).toList(),
        'unit_conversions': unitConversions.map((e) => e.toJson()).toList(),
      };

  double get sellingPriceAmount => double.tryParse(sellingPrice) ?? 0;
  double get purchasePriceAmount => double.tryParse(purchasePrice) ?? 0;

  // Get first available batch (FEFO - First Expired First Out)
  BatchModel? get firstAvailableBatch {
    final availableBatches = batches.where((b) => b.stock > 0).toList();
    if (availableBatches.isEmpty) return null;
    // Sort by expiry date ascending
    availableBatches.sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
    return availableBatches.first;
  }
}

class CategoryInfo {
  final int id;
  final String name;
  final CategoryTypeInfo? categoryType;

  CategoryInfo({
    required this.id,
    required this.name,
    this.categoryType,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryType: json['category_type'] != null
          ? CategoryTypeInfo.fromJson(json['category_type'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category_type': categoryType?.toJson(),
      };

  /// Get display color from category type, or default gray
  String get displayColor => categoryType?.color ?? '#6b7280';
}

class CategoryTypeInfo {
  final int id;
  final String name;
  final String code;
  final String? color;

  CategoryTypeInfo({
    required this.id,
    required this.name,
    required this.code,
    this.color,
  });

  factory CategoryTypeInfo.fromJson(Map<String, dynamic> json) {
    return CategoryTypeInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'color': color,
      };
}

class UnitInfo {
  final int id;
  final String name;

  UnitInfo({
    required this.id,
    required this.name,
  });

  factory UnitInfo.fromJson(Map<String, dynamic> json) {
    return UnitInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class BatchModel {
  final int id;
  final String batchNumber;
  final String expiredDate;
  final int stock;
  final String? purchasePrice;
  final String? sellingPrice;

  BatchModel({
    required this.id,
    required this.batchNumber,
    required this.expiredDate,
    required this.stock,
    this.purchasePrice,
    this.sellingPrice,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'] ?? 0,
      batchNumber: json['batch_number'] ?? '',
      expiredDate: json['expired_date'] ?? '',
      stock: json['stock'] ?? 0,
      purchasePrice: json['purchase_price']?.toString(),
      sellingPrice: json['selling_price']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'batch_number': batchNumber,
        'expired_date': expiredDate,
        'stock': stock,
        'purchase_price': purchasePrice,
        'selling_price': sellingPrice,
      };

  double get sellingPriceAmount =>
      double.tryParse(sellingPrice ?? '0') ?? 0;

  bool get isExpired {
    try {
      final expiry = DateTime.parse(expiredDate);
      return expiry.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool get isExpiringSoon {
    try {
      final expiry = DateTime.parse(expiredDate);
      final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
      return expiry.isBefore(thirtyDaysFromNow) && !isExpired;
    } catch (_) {
      return false;
    }
  }
}

class UnitConversionModel {
  final int id;
  final UnitInfo? unit;
  final double conversionValue;
  final String? sellingPrice;

  UnitConversionModel({
    required this.id,
    this.unit,
    required this.conversionValue,
    this.sellingPrice,
  });

  factory UnitConversionModel.fromJson(Map<String, dynamic> json) {
    // Parse conversion_value which can be String or num
    double convValue = 1;
    final rawConv = json['conversion_value'];
    if (rawConv is String) {
      convValue = double.tryParse(rawConv) ?? 1;
    } else if (rawConv is num) {
      convValue = rawConv.toDouble();
    }

    return UnitConversionModel(
      id: json['id'] ?? 0,
      unit: json['unit'] != null ? UnitInfo.fromJson(json['unit']) : null,
      conversionValue: convValue,
      sellingPrice: json['selling_price']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unit': unit?.toJson(),
        'conversion_value': conversionValue,
        'selling_price': sellingPrice,
      };

  double get sellingPriceAmount =>
      double.tryParse(sellingPrice ?? '0') ?? 0;
}
