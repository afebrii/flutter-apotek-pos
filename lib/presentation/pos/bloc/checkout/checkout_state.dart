import 'cart_item_model.dart';

class CheckoutState {
  final List<CartItemModel> items;
  final double discount;
  final double tax;
  final int? customerId;
  final String? customerName;
  final String? notes;

  CheckoutState({
    this.items = const [],
    this.discount = 0,
    this.tax = 0,
    this.customerId,
    this.customerName,
    this.notes,
  });

  // Calculate totals
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalDiscount => discount + items.fold(0, (sum, item) => sum + item.discount);
  double get grandTotal => subtotal - discount + tax;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CheckoutState copyWith({
    List<CartItemModel>? items,
    double? discount,
    double? tax,
    int? customerId,
    String? customerName,
    String? notes,
    bool clearCustomer = false,
  }) {
    return CheckoutState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      notes: notes ?? this.notes,
    );
  }

  CheckoutState clear() {
    return CheckoutState();
  }
}
