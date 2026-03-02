class PaymentMethodModel {
  final int id;
  final String name;
  final String code;
  final bool isCash;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.code,
    this.isCash = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isCash: json['is_cash'] ?? false,
    );
  }

  // Static payment methods based on backend seeder
  // IDs must match database: PaymentMethodSeeder.php
  static List<PaymentMethodModel> getDefaultMethods() {
    return [
      PaymentMethodModel(id: 1, name: 'Tunai', code: 'CASH', isCash: true),
      PaymentMethodModel(id: 2, name: 'Debit BCA', code: 'DEBIT_BCA', isCash: false),
      PaymentMethodModel(id: 3, name: 'Debit Mandiri', code: 'DEBIT_MANDIRI', isCash: false),
      PaymentMethodModel(id: 4, name: 'Debit BRI', code: 'DEBIT_BRI', isCash: false),
      PaymentMethodModel(id: 5, name: 'Debit BNI', code: 'DEBIT_BNI', isCash: false),
      PaymentMethodModel(id: 6, name: 'QRIS', code: 'QRIS', isCash: false),
      PaymentMethodModel(id: 7, name: 'GoPay', code: 'GOPAY', isCash: false),
      PaymentMethodModel(id: 8, name: 'OVO', code: 'OVO', isCash: false),
      PaymentMethodModel(id: 9, name: 'DANA', code: 'DANA', isCash: false),
      PaymentMethodModel(id: 10, name: 'ShopeePay', code: 'SHOPEEPAY', isCash: false),
      PaymentMethodModel(id: 11, name: 'LinkAja', code: 'LINKAJA', isCash: false),
      PaymentMethodModel(id: 12, name: 'Transfer Bank', code: 'TRANSFER', isCash: false),
      PaymentMethodModel(id: 13, name: 'Kredit', code: 'CREDIT', isCash: false),
    ];
  }
}
