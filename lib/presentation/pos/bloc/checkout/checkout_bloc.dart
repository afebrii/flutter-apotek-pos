import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_item_model.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutState()) {
    on<CheckoutAddItem>(_onAddItem);
    on<CheckoutUpdateQuantity>(_onUpdateQuantity);
    on<CheckoutUpdateItem>(_onUpdateItem);
    on<CheckoutRemoveItem>(_onRemoveItem);
    on<CheckoutClear>(_onClear);
    on<CheckoutSetDiscount>(_onSetDiscount);
    on<CheckoutSetCustomer>(_onSetCustomer);
    on<CheckoutSetNotes>(_onSetNotes);
  }

  void _onAddItem(
    CheckoutAddItem event,
    Emitter<CheckoutState> emit,
  ) {
    final items = List<CartItemModel>.from(state.items);

    // Determine the batch to use
    final batch = event.batch ?? event.product.firstAvailableBatch;

    // Check if product already in cart with same batch
    final existingIndex = items.indexWhere((item) =>
        item.product.id == event.product.id &&
        item.batch?.id == batch?.id);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existingItem = items[existingIndex];
      items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + event.quantity,
      );
    } else {
      // Add new item
      final price = batch?.sellingPriceAmount ?? event.product.sellingPriceAmount;

      items.add(CartItemModel(
        product: event.product,
        batch: batch,
        quantity: event.quantity,
        price: price,
      ));
    }

    emit(state.copyWith(items: items));
  }

  void _onUpdateQuantity(
    CheckoutUpdateQuantity event,
    Emitter<CheckoutState> emit,
  ) {
    if (event.index < 0 || event.index >= state.items.length) return;

    final items = List<CartItemModel>.from(state.items);

    if (event.quantity <= 0) {
      // Remove item if quantity is 0 or less
      items.removeAt(event.index);
    } else {
      // Update quantity
      items[event.index] = items[event.index].copyWith(
        quantity: event.quantity,
      );
    }

    emit(state.copyWith(items: items));
  }

  void _onUpdateItem(
    CheckoutUpdateItem event,
    Emitter<CheckoutState> emit,
  ) {
    final items = List<CartItemModel>.from(state.items);

    final index = items.indexWhere((item) =>
        item.product.id == event.productId &&
        item.batch?.id == event.batchId);

    if (index < 0) return;

    if (event.quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: event.quantity);
    }

    emit(state.copyWith(items: items));
  }

  void _onRemoveItem(
    CheckoutRemoveItem event,
    Emitter<CheckoutState> emit,
  ) {
    final items = List<CartItemModel>.from(state.items);

    if (event.index != null) {
      if (event.index! < 0 || event.index! >= items.length) return;
      items.removeAt(event.index!);
    } else if (event.productId != null) {
      final index = items.indexWhere((item) =>
          item.product.id == event.productId &&
          item.batch?.id == event.batchId);
      if (index >= 0) {
        items.removeAt(index);
      }
    }

    emit(state.copyWith(items: items));
  }

  void _onClear(
    CheckoutClear event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.clear());
  }

  void _onSetDiscount(
    CheckoutSetDiscount event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(discount: event.discount));
  }

  void _onSetCustomer(
    CheckoutSetCustomer event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(
      customerId: event.customerId,
      customerName: event.customerName,
      clearCustomer: event.customerId == null,
    ));
  }

  void _onSetNotes(
    CheckoutSetNotes event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(notes: event.notes));
  }
}
