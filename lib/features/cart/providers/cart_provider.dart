import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/cart/models/cart_item_model.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addToCart(ProductModel product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            CartItemModel(
              product: state[i].product,
              quantity: state[i].quantity + 1,
            )
          else
            state[i],
      ];
    } else {
      state = [...state, CartItemModel(product: product)];
    }
  }

  void updataQuantity(int productId, bool isIncrement) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          CartItemModel(
            product: item.product,
            quantity: isIncrement
                ? item.quantity + 1
                : (item.quantity > 1 ? item.quantity - 1 : 1),
          )
        else
          item,
    ];
  }

  void clearCart() {
    state = [];
  }

  double get totalPrice {
    return state.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((
  ref,
) {
  return CartNotifier();
});
