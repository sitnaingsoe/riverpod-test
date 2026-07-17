import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/cart/models/cart_item_model.dart';
import 'package:riverpod_test/features/orders/models/order_model.dart';
import 'package:riverpod_test/features/orders/services/order_service.dart';

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderModel>>(() {
  return OrdersNotifier();
});

class OrdersNotifier extends Notifier<List<OrderModel>> {
  final _service = OrderService();

  String? _firebaseUid;

  String? _hiveUserId;

  @override
  List<OrderModel> build() {
    ref.keepAlive();

    final authState = ref.watch(authProvider);

    return authState.maybeWhen(
      data: (user) {
        if (user != null) {
          _hiveUserId = user.id.toString();

          _firebaseUid = FirebaseAuth.instance.currentUser?.uid;

          final localOrders = _service.loadOrdersFromHive(_hiveUserId!);

          if (_firebaseUid != null) {
            Future.microtask(() => _syncFromFirestore());
          }

          return localOrders;
        }

        _hiveUserId = null;
        _firebaseUid = null;
        return [];
      },
      orElse: () {
        _hiveUserId = null;
        _firebaseUid = null;
        return [];
      },
    );
  }

  Future<void> _syncFromFirestore() async {
    if (_firebaseUid == null || _hiveUserId == null) return;
    try {
      final cloudOrders = await _service.syncOrdersFromFirestore(_firebaseUid!);

      if (cloudOrders.isNotEmpty) {
        await _service.saveOrdersToHive(_hiveUserId!, cloudOrders);
        state = cloudOrders;
      }
    } catch (e) {
      e.toString();
    }
  }

  Future<void> placeOrder({
    required List<CartItemModel> cartItems,
    required double total,
    required String address,
    required String phone,
  }) async {
    if (_hiveUserId == null || cartItems.isEmpty) return;

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

    state = updatedList;

    await _service.saveOrdersToHive(_hiveUserId!, updatedList);

    if (_firebaseUid != null) {
      try {
        await _service.saveOrderToFirestore(_firebaseUid!, newOrder);
      } catch (e) {
        e.toString();
      }
    }
  }
}
