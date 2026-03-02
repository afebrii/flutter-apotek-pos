class ReceiptModel {
  final ReceiptStore store;
  final ReceiptSale sale;
  final List<ReceiptItem> items;
  final ReceiptSummary summary;
  final List<ReceiptPayment> payments;

  ReceiptModel({
    required this.store,
    required this.sale,
    required this.items,
    required this.summary,
    required this.payments,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      store: ReceiptStore.fromJson(json['store'] ?? {}),
      sale: ReceiptSale.fromJson(json['sale'] ?? {}),
      items: (json['items'] as List?)
              ?.map((e) => ReceiptItem.fromJson(e))
              .toList() ??
          [],
      summary: ReceiptSummary.fromJson(json['summary'] ?? {}),
      payments: (json['payments'] as List?)
              ?.map((e) => ReceiptPayment.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReceiptStore {
  final String name;
  final String? address;
  final String? phone;
  final String? siaNumber;
  final String? pharmacistName;
  final String? pharmacistSipa;
  final String? receiptFooter;

  ReceiptStore({
    required this.name,
    this.address,
    this.phone,
    this.siaNumber,
    this.pharmacistName,
    this.pharmacistSipa,
    this.receiptFooter,
  });

  factory ReceiptStore.fromJson(Map<String, dynamic> json) {
    return ReceiptStore(
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      siaNumber: json['sia_number'],
      pharmacistName: json['pharmacist_name'],
      pharmacistSipa: json['pharmacist_sipa'],
      receiptFooter: json['receipt_footer'],
    );
  }
}

class ReceiptSale {
  final int id;
  final String invoiceNumber;
  final String date;
  final String time;
  final String cashier;
  final String customer;

  ReceiptSale({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.time,
    required this.cashier,
    required this.customer,
  });

  factory ReceiptSale.fromJson(Map<String, dynamic> json) {
    return ReceiptSale(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      cashier: json['cashier'] ?? '',
      customer: json['customer'] ?? 'Umum',
    );
  }
}

class ReceiptItem {
  final String name;
  final int quantity;
  final String unit;
  final String price;
  final String discount;
  final String subtotal;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.discount,
    required this.subtotal,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      price: json['price']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      subtotal: json['subtotal']?.toString() ?? '0',
    );
  }

  double get priceAmount => double.tryParse(price) ?? 0;
  double get discountAmount => double.tryParse(discount) ?? 0;
  double get subtotalAmount => double.tryParse(subtotal) ?? 0;
}

class ReceiptSummary {
  final String subtotal;
  final String discount;
  final String tax;
  final String total;
  final String paidAmount;
  final String changeAmount;

  ReceiptSummary({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
  });

  factory ReceiptSummary.fromJson(Map<String, dynamic> json) {
    return ReceiptSummary(
      subtotal: json['subtotal']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      tax: json['tax']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString() ?? '0',
      changeAmount: json['change_amount']?.toString() ?? '0',
    );
  }

  double get subtotalAmount => double.tryParse(subtotal) ?? 0;
  double get discountAmount => double.tryParse(discount) ?? 0;
  double get taxAmount => double.tryParse(tax) ?? 0;
  double get totalAmount => double.tryParse(total) ?? 0;
  double get paidAmountValue => double.tryParse(paidAmount) ?? 0;
  double get changeAmountValue => double.tryParse(changeAmount) ?? 0;
}

class ReceiptPayment {
  final String method;
  final String amount;

  ReceiptPayment({
    required this.method,
    required this.amount,
  });

  factory ReceiptPayment.fromJson(Map<String, dynamic> json) {
    return ReceiptPayment(
      method: json['method'] ?? '',
      amount: json['amount']?.toString() ?? '0',
    );
  }

  double get amountValue => double.tryParse(amount) ?? 0;
}
