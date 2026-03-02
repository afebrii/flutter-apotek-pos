class SaleRequestModel {
  final int? customerId;
  final List<SaleItemRequest> items;
  final double discount;
  final double tax;
  final List<PaymentRequest> payments;
  final String? notes;

  SaleRequestModel({
    this.customerId,
    required this.items,
    this.discount = 0,
    this.tax = 0,
    required this.payments,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        if (customerId != null) 'customer_id': customerId,
        'items': items.map((e) => e.toJson()).toList(),
        'discount': discount,
        'tax': tax,
        'payments': payments.map((e) => e.toJson()).toList(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

class SaleItemRequest {
  final int productId;
  final int batchId;
  final int? unitId;
  final int quantity;
  final double price;
  final double discount;

  SaleItemRequest({
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
        if (unitId != null) 'unit_id': unitId,
        'quantity': quantity,
        'price': price,
        'discount': discount,
      };
}

class PaymentRequest {
  final int paymentMethodId;
  final double amount;
  final String? referenceNumber;

  PaymentRequest({
    required this.paymentMethodId,
    required this.amount,
    this.referenceNumber,
  });

  Map<String, dynamic> toJson() => {
        'payment_method_id': paymentMethodId,
        'amount': amount,
        if (referenceNumber != null && referenceNumber!.isNotEmpty)
          'reference_number': referenceNumber,
      };
}
