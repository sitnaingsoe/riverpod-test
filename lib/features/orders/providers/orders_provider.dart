import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/cart/models/cart_item_model.dart';
import 'package:riverpod_test/features/orders/models/order_model.dart';

final Map<String, List<OrderModel>> _orders = {};

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderModel>>(() {
  return OrdersNotifier();
});

class OrdersNotifier extends Notifier<List<OrderModel>> {
  String? _userId;

  @override
  List<OrderModel> build() {
    ref.keepAlive();

    final authState = ref.watch(authProvider);

    return authState.maybeWhen(
      data: (user) {
        if (user != null) {
          _userId = user.id.toString();
          return List.from(_orders[_userId!] ??= []);
        }
        _userId = "GUEST_USER";
        return List.from(_orders[_userId!] ??= []);
      },
      orElse: () {
        _userId = "GUEST_USER";
        return List.from(_orders[_userId!] ??= []);
      },
    );
  }

  void placeOrder({
    required List<CartItemModel> cartItems,
    required double total,
    required String address,
    required String phone,
  }) {
    _userId ??= "GUEST_USER";

    if (cartItems.isEmpty) {
      return;
    }

    final newOrder = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(cartItems),
      totalAmount: total,
      orderDate: DateTime.now(),
      shippingAddress: address,
      phoneNumber: phone,
      paymentMethod: 'Cash on Delivery',
    );

    final updatedList = [newOrder, ...state];
    _orders[_userId!] = updatedList;
    state = updatedList;
  }
}
