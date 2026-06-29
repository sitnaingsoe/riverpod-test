import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart'; // သင့် AuthProvider လမ်းကြောင်း
import 'package:riverpod_test/features/cart/models/cart_item_model.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

class CartNotifier extends Notifier<List<CartItemModel>> {
  late Box _cartBox;
  String? _userId;
  final String _kCartBoxName = 'user_cart_box';

  @override
  List<CartItemModel> build() {
    _cartBox = Hive.box(_kCartBoxName);

    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          _userId = user.id.toString();
          final dynamicList = _cartBox.get(_userId) as List<dynamic>?;

          if (dynamicList != null) {
            return dynamicList.map((item) {
              return CartItemModel.fromJson(Map<String, dynamic>.from(item));
            }).toList();
          }
        } else {
          _userId = null;
        }
        return [];
      },
      loading: () => const [],
      error: (err, stack) => [],
    );
  }

  void _saveAndEmitState(List<CartItemModel> updatedList) async {
    state = updatedList;

    if (_userId != null) {
      final jsonList = updatedList.map((item) => item.toJson()).toList();
      await _cartBox.put(_userId, jsonList);
    }
  }

  void addToCart(ProductModel product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    List<CartItemModel> updatedList;

    if (index != -1) {
      updatedList = [
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
      updatedList = [...state, CartItemModel(product: product)];
    }

    _saveAndEmitState(updatedList);
  }

  void updateQuantity(int productId, bool isIncrement) {
    final updatedList = [
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

    _saveAndEmitState(updatedList);
  }

  void removeFromCart(int productId) {
    final updatedList = state
        .where((item) => item.product.id != productId)
        .toList();
    _saveAndEmitState(updatedList);
  }

  void clearCart() {
    final updatedList = <CartItemModel>[];
    _saveAndEmitState(updatedList);
  }

  double get totalPrice {
    return state.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(() {
  return CartNotifier();
});
