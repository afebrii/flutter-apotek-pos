import '../../../../data/models/responses/product_model.dart';

abstract class CheckoutEvent {}

class CheckoutAddItem extends CheckoutEvent {
  final ProductModel product;
  final BatchModel? batch;
  final int quantity;

  CheckoutAddItem({
    required this.product,
    this.batch,
    this.quantity = 1,
  });
}

class CheckoutUpdateQuantity extends CheckoutEvent {
  final int index;
  final int quantity;

  CheckoutUpdateQuantity({
    required this.index,
    required this.quantity,
  });
}

class CheckoutRemoveItem extends CheckoutEvent {
  final int? index;
  final int? productId;
  final int? batchId;

  CheckoutRemoveItem({
    this.index,
    this.productId,
    this.batchId,
  });
}

class CheckoutUpdateItem extends CheckoutEvent {
  final int productId;
  final int? batchId;
  final int quantity;

  CheckoutUpdateItem({
    required this.productId,
    this.batchId,
    required this.quantity,
  });
}

class CheckoutClear extends CheckoutEvent {}

class CheckoutSetDiscount extends CheckoutEvent {
  final double discount;

  CheckoutSetDiscount({required this.discount});
}

class CheckoutSetCustomer extends CheckoutEvent {
  final int? customerId;
  final String? customerName;

  CheckoutSetCustomer({
    this.customerId,
    this.customerName,
  });
}

class CheckoutSetNotes extends CheckoutEvent {
  final String? notes;

  CheckoutSetNotes({this.notes});
}
