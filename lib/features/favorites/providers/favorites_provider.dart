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
          try {
            final doc = await _firestore
                .collection('favorites')
                .doc(_userId)
                .get();

            if (doc.exists && doc.data() != null) {
              final data = doc.data()!;
              final List<dynamic>? items = data['items'];
              if (items != null) {
                return items.map((item) {
                  return ProductModel.fromJson(Map<String, dynamic>.from(item));
                }).toList();
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("❌ Error occurred while retrieving favorites: $e");
            }
          }
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
    final isExist = currentList.any((item) => item.id == product.id);
    List<ProductModel> updatedList;

    if (isExist) {
      updatedList = currentList.where((item) => item.id != product.id).toList();
    } else {
      updatedList = [...currentList, product];
    }
    final previousState = state;
    state = AsyncData(updatedList);
    try {
      final jsonList = updatedList.map((item) => item.toJson()).toList();
      await _firestore.collection('favorites').doc(_userId).set({
        'items': jsonList,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print("❌ Error updating Firestore database: $e");
      state = previousState;
    }
  }

  bool isFavorite(int productId) {
    final currentList = state.value ?? [];
    return currentList.any((item) => item.id == productId);
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<ProductModel>>(() {
      return FavoritesNotifier();
    });
