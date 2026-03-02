class SalesReportModel {
  final ReportPeriod period;
  final ReportSummary summary;
  final List<DailySales> dailySales;
  final List<TopProduct> topProducts;
  final List<PaymentMethodSummary> paymentMethods;

  SalesReportModel({
    required this.period,
    required this.summary,
    required this.dailySales,
    required this.topProducts,
    required this.paymentMethods,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      period: ReportPeriod.fromJson(json['period'] ?? {}),
      summary: ReportSummary.fromJson(json['summary'] ?? {}),
      dailySales: (json['daily_sales'] as List? ?? [])
          .map((e) => DailySales.fromJson(e))
          .toList(),
      topProducts: (json['top_products'] as List? ?? [])
          .map((e) => TopProduct.fromJson(e))
          .toList(),
      paymentMethods: (json['payment_methods'] as List? ?? [])
          .map((e) => PaymentMethodSummary.fromJson(e))
          .toList(),
    );
  }
}

class ReportPeriod {
  final String startDate;
  final String endDate;

  ReportPeriod({
    required this.startDate,
    required this.endDate,
  });

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

class ReportSummary {
  final int totalTransactions;
  final double totalSales;
  final double totalDiscount;
  final double averageTransaction;

  ReportSummary({
    required this.totalTransactions,
    required this.totalSales,
    required this.totalDiscount,
    required this.averageTransaction,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalTransactions: json['total_transactions'] ?? 0,
      totalSales: _parseDouble(json['total_sales']),
      totalDiscount: _parseDouble(json['total_discount']),
      averageTransaction: _parseDouble(json['average_transaction']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}

class DailySales {
  final String date;
  final int transactions;
  final double total;

  DailySales({
    required this.date,
    required this.transactions,
    required this.total,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'] ?? '',
      transactions: json['transactions'] ?? 0,
      total: _parseDouble(json['total']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}

class TopProduct {
  final int id;
  final String name;
  final String code;
  final int totalQty;
  final double totalSales;

  TopProduct({
    required this.id,
    required this.name,
    required this.code,
    required this.totalQty,
    required this.totalSales,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      totalQty: json['total_qty'] ?? 0,
      totalSales: _parseDouble(json['total_sales']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}

class PaymentMethodSummary {
  final String name;
  final int count;
  final double total;

  PaymentMethodSummary({
    required this.name,
    required this.count,
    required this.total,
  });

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      total: _parseDouble(json['total']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}
