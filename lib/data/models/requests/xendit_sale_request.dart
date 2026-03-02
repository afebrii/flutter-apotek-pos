class XenditSaleRequest {
  final int? customerId;
  final List<XenditSaleItem> items;
  final double discount;
  final double tax;
  final String? notes;
  final String paymentMethodCode;

  XenditSaleRequest({
    this.customerId,
    required this.items,
    this.discount = 0,
    this.tax = 0,
    this.notes,
    required this.paymentMethodCode,
  });

  Map<String, dynamic> toJson() => {
        if (customerId != null) 'customer_id': customerId,
        'items': items.map((e) => e.toJson()).toList(),
        'discount': discount,
        'tax': tax,
        if (notes != null) 'notes': notes,
        'payment_method_code': paymentMethodCode,
      };
}

class XenditSaleItem {
  final int productId;
  final int batchId;
  final int? unitId;
  final int quantity;
  final double price;
  final double discount;

  XenditSaleItem({
    required this.productId,
    required this.batchId,
    this.unitId,
    required this.quantity,
    required this.price,
    this.discount = 0,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'batch_id': batchId,
        'unit_id': unitId,
        'quantity': quantity,
        'price': price,
        'discount': discount,
      };
}
