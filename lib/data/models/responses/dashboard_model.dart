class DashboardSummaryModel {
  final TodaySales todaySales;
  final int lowStockProducts;
  final int expiringSoon;
  final int expiredProducts;
  final ActiveShiftInfo? activeShift;

  DashboardSummaryModel({
    required this.todaySales,
    required this.lowStockProducts,
    required this.expiringSoon,
    required this.expiredProducts,
    this.activeShift,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      todaySales: TodaySales.fromJson(json['today_sales'] ?? {}),
      lowStockProducts: json['low_stock_products'] ?? 0,
      expiringSoon: json['expiring_soon'] ?? 0,
      expiredProducts: json['expired_products'] ?? 0,
      activeShift: json['active_shift'] != null
          ? ActiveShiftInfo.fromJson(json['active_shift'])
          : null,
    );
  }
}

class TodaySales {
  final int count;
  final double total;

  TodaySales({
    required this.count,
    required this.total,
  });

  factory TodaySales.fromJson(Map<String, dynamic> json) {
    final totalValue = json['total'];
    double total = 0;
    if (totalValue is String) {
      total = double.tryParse(totalValue) ?? 0;
    } else if (totalValue != null) {
      total = (totalValue as num).toDouble();
    }

    return TodaySales(
      count: json['count'] ?? 0,
      total: total,
    );
  }
}

class ActiveShiftInfo {
  final int id;
  final double openingCash;
  final double expectedCash;
  final String openingTime;

  ActiveShiftInfo({
    required this.id,
    required this.openingCash,
    required this.expectedCash,
    required this.openingTime,
  });

  factory ActiveShiftInfo.fromJson(Map<String, dynamic> json) {
    return ActiveShiftInfo(
      id: json['id'] ?? 0,
      openingCash: _parseDouble(json['opening_cash']),
      expectedCash: _parseDouble(json['expected_cash']),
      openingTime: json['opening_time'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}

class LowStockProductModel {
  final int id;
  final String code;
  final String name;
  final String? category;
  final String? unit;
  final int totalStock;
  final int minStock;

  LowStockProductModel({
    required this.id,
    required this.code,
    required this.name,
    this.category,
    this.unit,
    required this.totalStock,
    required this.minStock,
  });

  factory LowStockProductModel.fromJson(Map<String, dynamic> json) {
    return LowStockProductModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      unit: json['unit'],
      totalStock: json['total_stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
    );
  }

  int get deficit => minStock - totalStock;
}

class ExpiringBatchModel {
  final int id;
  final String batchNumber;
  final ExpiringProductInfo product;
  final String? unit;
  final int stock;
  final String expiredDate;
  final int daysUntilExpiry;
  final bool isExpired;

  ExpiringBatchModel({
    required this.id,
    required this.batchNumber,
    required this.product,
    this.unit,
    required this.stock,
    required this.expiredDate,
    required this.daysUntilExpiry,
    required this.isExpired,
  });

  factory ExpiringBatchModel.fromJson(Map<String, dynamic> json) {
    return ExpiringBatchModel(
      id: json['id'] ?? 0,
      batchNumber: json['batch_number'] ?? '',
      product: ExpiringProductInfo.fromJson(json['product'] ?? {}),
      unit: json['unit'],
      stock: json['stock'] ?? 0,
      expiredDate: json['expired_date'] ?? '',
      daysUntilExpiry: json['days_until_expiry'] ?? 0,
      isExpired: json['is_expired'] ?? false,
    );
  }
}

class ExpiringProductInfo {
  final int id;
  final String name;
  final String code;

  ExpiringProductInfo({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ExpiringProductInfo.fromJson(Map<String, dynamic> json) {
    return ExpiringProductInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}
