import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart'; // သင့် AuthProvider လမ်းကြောင်း
import 'package:riverpod_test/features/cart/models/cart_item_model.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

final String _kCartBoxName = 'user_cart_box';

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box _cartBox;
  String? firebaseUid;
  String? _userId;

  @override
  Future<List<CartItemModel>> build() async {
    _cartBox = Hive.box(_kCartBoxName);

    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          _userId = user.id.toString();
          List<CartItemModel> localCart = [];
          final dynamicList = _cartBox.get(_userId) as List<dynamic>?;
          firebaseUid = FirebaseAuth.instance.currentUser?.uid;
          if (dynamicList != null) {
            localCart = dynamicList.map((item) {
              return CartItemModel.fromJson(Map<String, dynamic>.from(item));
            }).toList();
          }
          _syncCartWithFirestoreInBackground();
          return localCart;
        } else {
          _userId = null;
        }
        return [];
      },
      loading: () => const [],
      error: (err, stack) => [],
    );
  }

  Future<void> _syncCartWithFirestoreInBackground() async {
    if (_userId == null || firebaseUid == null) return;
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(firebaseUid)
          .collection('cart')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final cloudCart = querySnapshot.docs.map((doc) {
          return CartItemModel.fromJson(doc.data());
        }).toList();

        final jsonList = cloudCart.map((item) => item.toJson()).toList();
        await _cartBox.put(_userId, jsonList);
        state = AsyncData(cloudCart);
      }
    } catch (e) {
      e.toString();
    }
  }

  void addToCart(ProductModel product) async {
    if (_userId == null) return;
    final currentLsit = state.value ?? [];
    List<CartItemModel> updatedList = List.from(currentLsit);
    final index = updatedList.indexWhere(
      (item) => item.product.id == product.id,
    );
    late CartItemModel updatedItem;
    if (index != -1) {
      final currentItem = updatedList[index];
      updatedItem = CartItemModel(
        product: currentItem.product,
        quantity: currentItem.quantity + 1,
      );
      updatedList[index] = updatedItem;
    } else {
      updatedItem = CartItemModel(product: product, quantity: 1);
      updatedList.add(updatedItem);
    }

    final previousState = state;
    state = AsyncData(updatedList);
    try {
      final jsonList = updatedList.map((item) => item.toJson()).toList();
      await Future.wait([
        _cartBox.put(_userId, jsonList),
        _firestore
            .collection('users')
            .doc(firebaseUid)
            .collection('cart')
            .doc(product.id.toString())
            .set(updatedItem.toJson(), SetOptions(merge: true)),
      ]);
    } catch (e) {
      state = previousState;
      final rollbackJsonList = (previousState.value ?? [])
          .map((item) => item.toJson())
          .toList();
      await _cartBox.put(_userId, rollbackJsonList);
    }
  }

  void removeFromCart(ProductModel product) async {
    if (_userId == null || firebaseUid == null) return;
    final currentList = state.value ?? [];
    List<CartItemModel> updatedList = List.from(currentList);
    final index = currentList.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1) {
      final currentItem = updatedList[index];
      if (currentItem.quantity > 1) {
        final updatedItem = CartItemModel(
          product: currentItem.product,
          quantity: currentItem.quantity - 1,
        );
        updatedList[index] = updatedItem;
        final previousState = state;
        state = AsyncData(updatedList);

        try {
          final jsonList = updatedList.map((item) => item.toJson()).toList();
          await Future.wait([
            _cartBox.put(_userId, jsonList),
            _firestore
                .collection('users')
                .doc(firebaseUid)
                .collection('cart')
                .doc(product.id.toString()) // <-- ID ဖြင့် Update လုပ်ပါသည်
                .set(updatedItem.toJson(), SetOptions(merge: true)),
          ]);
        } catch (e) {
          state = previousState;
          final rollbackJsonList = (previousState.value ?? [])
              .map((item) => item.toJson())
              .toList();
          await _cartBox.put(_userId, rollbackJsonList);
        }
      } else {
        updatedList.removeAt(index);
      }
    } else {
      deleteItemFromCart(product);
    }
  }

  void deleteItemFromCart(ProductModel product) async {
    if (_userId == null || firebaseUid == null) return;

    final currentList = state.value ?? [];
    final updatedList = currentList
        .where((item) => item.product.id != product.id)
        .toList();

    final previousState = state;
    state = AsyncData(updatedList);
    try {
      final jsonList = updatedList.map((item) => item.toJson()).toList();
      await Future.wait([
        _cartBox.put(_userId, jsonList),
        _firestore
            .collection('users')
            .doc(firebaseUid)
            .collection('cart')
            .doc(product.id.toString())
            .delete(),
      ]);
    } catch (e) {
      state = previousState;
      final rollbackJsonList = (previousState.value ?? [])
          .map((item) => item.toJson())
          .toList();
      await _cartBox.put(_userId, rollbackJsonList);
    }
  }

  Future<void> clearCart() async {
    if (_userId == null || firebaseUid == null) return;
    final previousState = state;
    state = const AsyncData([]);
    try {
      await _cartBox.put(_userId, []);
      final snapshots = await _firestore
          .collection('users')
          .doc(firebaseUid)
          .collection('cart')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      state = previousState;
      final rollbackJsonList = (previousState.value ?? [])
          .map((item) => item.toJson())
          .toList();
      await _cartBox.put(_userId, rollbackJsonList);
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  () {
    return CartNotifier();
  },
);

final totalCartCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);

  return cartState.maybeWhen(
    data: (cartList) {
      // ignore: avoid_types_as_parameter_names
      return cartList.fold<int>(0, (sum, item) => sum + item.quantity);
    },
    orElse: () => 0,
  );
});
final cartTotalPriceProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);

  return cartState.maybeWhen(
    data: (cartList) {
      return cartList.fold<double>(
        0.0,
        // ignore: avoid_types_as_parameter_names
        (sum, item) => sum + (item.product.price * item.quantity),
      );
    },
    orElse: () => 0.0,
  );
});
