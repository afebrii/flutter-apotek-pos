import '../../../../data/models/responses/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final BatchModel? batch;
  final int quantity;
  final double price;
  final double discount;

  CartItemModel({
    required this.product,
    this.batch,
    required this.quantity,
    required this.price,
    this.discount = 0,
  });

  double get subtotal => (price * quantity) - discount;

  CartItemModel copyWith({
    ProductModel? product,
    BatchModel? batch,
    int? quantity,
    double? price,
    double? discount,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      batch: batch ?? this.batch,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discount: discount ?? this.discount,
    );
  }

  // Get unit name
  String get unitName => product.baseUnit?.name ?? 'Pcs';

  // Check if batch is expired
  bool get isBatchExpired => batch?.isExpired ?? false;

  // Check if batch is expiring soon
  bool get isBatchExpiringSoon => batch?.isExpiringSoon ?? false;
}
