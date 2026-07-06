import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

const String kFavoritesBoxName = 'user_favorites_box';

class FavoritesNotifier extends AsyncNotifier<List<ProductModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box _favoriteBox;

  String? _userId;

  @override
  Future<List<ProductModel>> build() async {
    _favoriteBox = Hive.box(kFavoritesBoxName);

    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) async {
        if (user != null) {
          _userId = user.id.toString();
          if (kDebugMode) {
            print("🎯 Current Login User ID is: $_userId");
          }
          List<ProductModel> localFavorites = [];

          final List<dynamic> dyanmicList =
              _favoriteBox.get(_userId) as List<dynamic>? ?? [];
          if (dyanmicList.isNotEmpty) {
            localFavorites = dyanmicList.map((item) {
              return ProductModel.fromJson(Map<String, dynamic>.from(item));
            }).toList();
          }

          _syncWithFirestoreInBackground();
          return localFavorites;
        } else {
          if (kDebugMode) {
            print("👤 User is NULL inside FavoritesNotifier!");
          }
          _userId = null;
        }
        return [];
      },
      loading: () => const [],
      error: (err, stack) => [],
    );
  }

  void toggleFavorite(ProductModel product) async {
    if (_userId == null) return;

    final currentList = state.value ?? [];

    final index = currentList.indexWhere((item) => item.id == product.id);

    final isExist = index != -1;
    List<ProductModel> updatedList = List.from(currentList);

    if (isExist) {
      updatedList.removeAt(index);
    } else {
      updatedList.add(product);
    }
    final previousJsonList = currentList.map((item) => item.toJson()).toList();
    final updatedJsonList = updatedList.map((item) => item.toJson()).toList();

    final previousState = state;
    state = AsyncData(updatedList);
    try {
      await Future.wait([
        _favoriteBox.put(_userId, updatedJsonList),
        _firestore.collection('favorites').doc(_userId).set({
          'items': updatedJsonList,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
      ]);
    } catch (e) {
      if (kDebugMode) print("❌ Error updating storage databases: $e");
      state = previousState;
      await _favoriteBox.put(_userId, previousJsonList);
    }
    // final isExist = currentList.any((item) => item.id == product.id);
    // List<ProductModel> updatedList;

    // if (isExist) {
    //   updatedList = currentList.where((item) => item.id != product.id).toList();
    // } else {
    //   updatedList = [...currentList, product];
    // }
    // final previousState = state;
    // state = AsyncData(updatedList);
    // try {
    //   final jsonList = updatedList.map((item) => item.toJson()).toList();
    //   await _favoriteBox.put(_userId, jsonList);
    //   await _firestore.collection('favorites').doc(_userId).set({
    //     'items': jsonList,
    //     'updatedAt': FieldValue.serverTimestamp(),
    //   }, SetOptions(merge: true));
    // } catch (e) {
    //   if (kDebugMode) print("❌ Error updating Firestore database: $e");
    //   state = previousState;
    //   final rollbackJsonList = (previousState.value ?? [])
    //       .map((item) => item.toJson())
    //       .toList();
    //   await _favoriteBox.put(_userId, rollbackJsonList);
    // }
  }

  bool isFavorite(int productId) {
    final currentList = state.value ?? [];
    return currentList.any((item) => item.id == productId);
  }

  Future<void> _syncWithFirestoreInBackground() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('favorites').doc(_userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final List<dynamic>? items = data['items'] ?? [];
        if (items != null) {
          final cloudFavorites = items.map((item) {
            return ProductModel.fromJson(Map<String, dynamic>.from(item));
          }).toList();

          final jsonList = cloudFavorites.map((item) => item.toJson()).toList();
          await _favoriteBox.put(_userId, jsonList);
          state = AsyncData(cloudFavorites);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("☁️ Firestore Sync Error  $e");
      }
    }
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<ProductModel>>(() {
      return FavoritesNotifier();
    });
