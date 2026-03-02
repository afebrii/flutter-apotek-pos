class TransactionModel {
  final int id;
  final String invoiceNumber;
  final String date;
  final TransactionCustomer? customer;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String status;

  TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    this.customer,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      date: json['date'] ?? '',
      customer: json['customer'] != null
          ? TransactionCustomer.fromJson(json['customer'])
          : null,
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      status: json['status'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}

class TransactionCustomer {
  final int id;
  final String name;

  TransactionCustomer({
    required this.id,
    required this.name,
  });

  factory TransactionCustomer.fromJson(Map<String, dynamic> json) {
    return TransactionCustomer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class TransactionDetailModel {
  final int id;
  final String invoiceNumber;
  final String date;
  final TransactionDetailCustomer? customer;
  final TransactionCashier cashier;
  final List<TransactionItem> items;
  final List<TransactionPayment> payments;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String status;
  final double paidAmount;
  final double changeAmount;
  final String? notes;

  TransactionDetailModel({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    this.customer,
    required this.cashier,
    required this.items,
    required this.payments,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    required this.paidAmount,
    required this.changeAmount,
    this.notes,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      date: json['date'] ?? '',
      customer: json['customer'] != null
          ? TransactionDetailCustomer.fromJson(json['customer'])
          : null,
      cashier: TransactionCashier.fromJson(json['cashier'] ?? {}),
      items: (json['items'] as List? ?? [])
          .map((e) => TransactionItem.fromJson(e))
          .toList(),
      payments: (json['payments'] as List? ?? [])
          .map((e) => TransactionPayment.fromJson(e))
          .toList(),
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      status: json['status'] ?? '',
      paidAmount: _parseDouble(json['paid_amount']),
      changeAmount: _parseDouble(json['change_amount']),
      notes: json['notes'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}

class TransactionDetailCustomer {
  final int id;
  final String name;
  final String? phone;

  TransactionDetailCustomer({
    required this.id,
    required this.name,
    this.phone,
  });

  factory TransactionDetailCustomer.fromJson(Map<String, dynamic> json) {
    return TransactionDetailCustomer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
    );
  }
}

class TransactionCashier {
  final int id;
  final String name;

  TransactionCashier({
    required this.id,
    required this.name,
  });

  factory TransactionCashier.fromJson(Map<String, dynamic> json) {
    return TransactionCashier(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class TransactionItem {
  final int id;
  final TransactionProduct product;
  final String? batchNumber;
  final String? unit;
  final int quantity;
  final double price;
  final double discount;
  final double subtotal;

  TransactionItem({
    required this.id,
    required this.product,
    this.batchNumber,
    this.unit,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] ?? 0,
      product: TransactionProduct.fromJson(json['product'] ?? {}),
      batchNumber: json['batch_number'],
      unit: json['unit'],
      quantity: json['quantity'] ?? 0,
      price: _parseDouble(json['price']),
      discount: _parseDouble(json['discount']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
  }
}

class TransactionProduct {
  final int id;
  final String name;
  final String code;

  TransactionProduct({
    required this.id,
    required this.name,
    required this.code,
  });

  factory TransactionProduct.fromJson(Map<String, dynamic> json) {
    return TransactionProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class TransactionPayment {
  final int id;
  final PaymentMethodInfo? paymentMethod;
  final double amount;
  final String? reference;

  TransactionPayment({
    required this.id,
    this.paymentMethod,
    required this.amount,
    this.reference,
  });

  factory TransactionPayment.fromJson(Map<String, dynamic> json) {
    return TransactionPayment(
      id: json['id'] ?? 0,
      paymentMethod: json['payment_method'] != null
          ? PaymentMethodInfo.fromJson(json['payment_method'])
          : null,
      amount: _parseDouble(json['amount']),
      reference: json['reference'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return (value as num).toDouble();
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
