class ShiftSummaryModel {
  final ShiftInfo shift;
  final SalesSummary sales;
  final CashFlowSummary cashFlow;
  final List<PaymentMethodSummary> paymentMethods;

  ShiftSummaryModel({
    required this.shift,
    required this.sales,
    required this.cashFlow,
    required this.paymentMethods,
  });

  factory ShiftSummaryModel.fromJson(Map<String, dynamic> json) {
    return ShiftSummaryModel(
      shift: ShiftInfo.fromJson(json['shift'] ?? {}),
      sales: SalesSummary.fromJson(json['sales'] ?? {}),
      cashFlow: CashFlowSummary.fromJson(json['cash_flow'] ?? {}),
      paymentMethods: (json['payment_methods'] as List?)
              ?.map((e) => PaymentMethodSummary.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ShiftInfo {
  final int id;
  final String openingCash;
  final String expectedCash;
  final DateTime openingTime;
  final String? duration;

  ShiftInfo({
    required this.id,
    required this.openingCash,
    required this.expectedCash,
    required this.openingTime,
    this.duration,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) {
    return ShiftInfo(
      id: json['id'] ?? 0,
      openingCash: json['opening_cash']?.toString() ?? '0',
      expectedCash: json['expected_cash']?.toString() ?? '0',
      openingTime: DateTime.parse(json['opening_time'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'],
    );
  }

  double get openingCashAmount => double.tryParse(openingCash) ?? 0;
  double get expectedCashAmount => double.tryParse(expectedCash) ?? 0;
}

class SalesSummary {
  final int totalTransactions;
  final String totalSales;
  final int cancelledCount;
  final String averageTransaction;

  SalesSummary({
    required this.totalTransactions,
    required this.totalSales,
    required this.cancelledCount,
    required this.averageTransaction,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalTransactions: json['total_transactions'] ?? 0,
      totalSales: json['total_sales']?.toString() ?? '0',
      cancelledCount: json['cancelled_count'] ?? 0,
      averageTransaction: json['average_transaction']?.toString() ?? '0',
    );
  }

  double get totalSalesAmount => double.tryParse(totalSales) ?? 0;
  double get averageTransactionAmount => double.tryParse(averageTransaction) ?? 0;
}

class CashFlowSummary {
  final String openingCash;
  final String cashSales;
  final String nonCashSales;
  final String expectedCash;

  CashFlowSummary({
    required this.openingCash,
    required this.cashSales,
    required this.nonCashSales,
    required this.expectedCash,
  });

  factory CashFlowSummary.fromJson(Map<String, dynamic> json) {
    return CashFlowSummary(
      openingCash: json['opening_cash']?.toString() ?? '0',
      cashSales: json['cash_sales']?.toString() ?? '0',
      nonCashSales: json['non_cash_sales']?.toString() ?? '0',
      expectedCash: json['expected_cash']?.toString() ?? '0',
    );
  }

  double get openingCashAmount => double.tryParse(openingCash) ?? 0;
  double get cashSalesAmount => double.tryParse(cashSales) ?? 0;
  double get nonCashSalesAmount => double.tryParse(nonCashSales) ?? 0;
  double get expectedCashAmount => double.tryParse(expectedCash) ?? 0;
}

class PaymentMethodSummary {
  final String name;
  final bool isCash;
  final int count;
  final String total;

  PaymentMethodSummary({
    required this.name,
    required this.isCash,
    required this.count,
    required this.total,
  });

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      name: json['name'] ?? '',
      isCash: json['is_cash'] ?? false,
      count: json['count'] ?? 0,
      total: json['total']?.toString() ?? '0',
    );
  }

  double get totalAmount => double.tryParse(total) ?? 0;
}

// For shift sales list
class ShiftSaleModel {
  final int id;
  final String invoiceNumber;
  final String customer;
  final String total;
  final String status;
  final String paymentMethod;
  final String time;

  ShiftSaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.customer,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.time,
  });

  factory ShiftSaleModel.fromJson(Map<String, dynamic> json) {
    return ShiftSaleModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      customer: json['customer'] ?? 'Umum',
      total: json['total']?.toString() ?? '0',
      status: json['status'] ?? 'completed',
      paymentMethod: json['payment_method'] ?? '',
      time: json['time'] ?? '',
    );
  }

  double get totalAmount => double.tryParse(total) ?? 0;
}

class ShiftSalesResponse {
  final List<ShiftSaleModel> sales;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ShiftSalesResponse({
    required this.sales,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ShiftSalesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] ?? {};

    List<ShiftSaleModel> sales = [];
    if (data is List) {
      sales = data.map((e) => ShiftSaleModel.fromJson(e)).toList();
    }

    return ShiftSalesResponse(
      sales: sales,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      perPage: meta['per_page'] ?? 20,
      total: meta['total'] ?? sales.length,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
}
