class SaleModel {
  final int id;
  final String invoiceNumber;
  final String date;
  final CustomerInfo? customer;
  final CashierInfo? cashier;
  final List<SaleItemModel> items;
  final List<SalePaymentModel> payments;
  final String subtotal;
  final String discount;
  final String tax;
  final String total;
  final String status;
  final String? paidAmount;
  final String? changeAmount;
  final String? notes;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    this.customer,
    this.cashier,
    this.items = const [],
    this.payments = const [],
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    this.paidAmount,
    this.changeAmount,
    this.notes,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      date: json['date'] ?? '',
      customer: json['customer'] != null
          ? CustomerInfo.fromJson(json['customer'])
          : null,
      cashier: json['cashier'] != null
          ? CashierInfo.fromJson(json['cashier'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => SaleItemModel.fromJson(e))
              .toList()
          : [],
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((e) => SalePaymentModel.fromJson(e))
              .toList()
          : [],
      subtotal: json['subtotal']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      tax: json['tax']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      status: json['status'] ?? 'completed',
      paidAmount: json['paid_amount']?.toString(),
      changeAmount: json['change_amount']?.toString(),
      notes: json['notes'],
    );
  }

  double get totalAmount => double.tryParse(total) ?? 0;
  double get changeAmountValue => double.tryParse(changeAmount ?? '0') ?? 0;
}

class CustomerInfo {
  final int id;
  final String name;
  final String? phone;

  CustomerInfo({
    required this.id,
    required this.name,
    this.phone,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
    );
  }
}

class CashierInfo {
  final int id;
  final String name;

  CashierInfo({
    required this.id,
    required this.name,
  });

  factory CashierInfo.fromJson(Map<String, dynamic> json) {
    return CashierInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SaleItemModel {
  final int id;
  final ProductInfo? product;
  final String? batchNumber;
  final String unit;
  final int quantity;
  final String price;
  final String discount;
  final String subtotal;

  SaleItemModel({
    required this.id,
    this.product,
    this.batchNumber,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] ?? 0,
      product: json['product'] != null
          ? ProductInfo.fromJson(json['product'])
          : null,
      batchNumber: json['batch_number'],
      unit: json['unit'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      subtotal: json['subtotal']?.toString() ?? '0',
    );
  }
}

class ProductInfo {
  final int id;
  final String name;
  final String code;

  ProductInfo({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class SalePaymentModel {
  final int id;
  final PaymentMethodInfo? paymentMethod;
  final String amount;
  final String? reference;

  SalePaymentModel({
    required this.id,
    this.paymentMethod,
    required this.amount,
    this.reference,
  });

  factory SalePaymentModel.fromJson(Map<String, dynamic> json) {
    return SalePaymentModel(
      id: json['id'] ?? 0,
      paymentMethod: json['payment_method'] != null
          ? PaymentMethodInfo.fromJson(json['payment_method'])
          : null,
      amount: json['amount']?.toString() ?? '0',
      reference: json['reference'],
    );
  }
}

class PaymentMethodInfo {
  final int id;
  final String name;

  PaymentMethodInfo({
    required this.id,
    required this.name,
  });

  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMethodInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// Response for create sale
class CreateSaleResponse {
  final bool success;
  final String? message;
  final int? saleId;
  final String? invoiceNumber;
  final String? total;
  final String? change;

  CreateSaleResponse({
    required this.success,
    this.message,
    this.saleId,
    this.invoiceNumber,
    this.total,
    this.change,
  });

  factory CreateSaleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CreateSaleResponse(
      success: json['success'] ?? false,
      message: json['message'],
      saleId: data?['id'],
      invoiceNumber: data?['invoice_number'],
      total: data?['total']?.toString(),
      change: data?['change']?.toString(),
    );
  }

  double get changeAmount => double.tryParse(change ?? '0') ?? 0;
}
