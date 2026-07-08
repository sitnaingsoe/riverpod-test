import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  /// Raw Firebase UID — used for Firestore path (users/{uid}/orders)
  String? _firebaseUid;

  /// Hashed int ID — used for Hive key (user_{id})
  String? _hiveUserId;

  @override
  List<OrderModel> build() {
    ref.keepAlive();

    final authState = ref.watch(authProvider);

    return authState.maybeWhen(
      data: (user) {
        if (user != null) {
          // Hive key uses the hashed int id (consistent with cart/favorites)
          _hiveUserId = user.id.toString();

          // Firestore path uses the real Firebase UID string
          _firebaseUid = FirebaseAuth.instance.currentUser?.uid;

          // ✅ 1. Load from Hive instantly (no spinner)
          final localOrders = _service.loadOrdersFromHive(_hiveUserId!);

          // ✅ 2. Sync from Firestore in background
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

  /// Background Firestore sync — updates Hive cache and UI state.
  Future<void> _syncFromFirestore() async {
    if (_firebaseUid == null || _hiveUserId == null) return;
    try {
      final cloudOrders = await _service.syncOrdersFromFirestore(_firebaseUid!);

      if (cloudOrders.isNotEmpty) {
        // Update Hive cache with latest cloud data
        await _service.saveOrdersToHive(_hiveUserId!, cloudOrders);
        state = cloudOrders;
        if (kDebugMode) {
          print('☁️ Orders synced from Firestore: ${cloudOrders.length} orders');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Orders Firestore sync failed: $e');
      // Silently fail — Hive data is already shown
    }
  }

  /// Places a new order — writes to Hive + Firestore simultaneously.
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

    // ✅ Optimistic update — UI responds instantly
    state = updatedList;

    // ✅ Persist locally
    await _service.saveOrdersToHive(_hiveUserId!, updatedList);

    // ✅ Save to Firestore (cloud)
    if (_firebaseUid != null) {
      try {
        await _service.saveOrderToFirestore(_firebaseUid!, newOrder);
      } catch (e) {
        // Order is already saved to Hive — user won't lose it
        if (kDebugMode) print('❌ Firestore order save failed: $e');
      }
    }
  }
}
