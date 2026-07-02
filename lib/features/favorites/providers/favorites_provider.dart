import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

const String kFavoritesBoxName = 'user_favorites_box';

class FavoritesNotifier extends AsyncNotifier<List<ProductModel>> {
  late Box _favoriteBox;
  String? _userId;

  @override
  Future<List<ProductModel>> build() async {
    _favoriteBox = Hive.box(kFavoritesBoxName);
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          _userId = user.id.toString();
          if (kDebugMode) {
            print("🎯 Current Login User ID is: $_userId");
          }

          final List<dynamic>? dynamicList = _favoriteBox.get(_userId);

          if (kDebugMode) {
            print("📦 Retrieved Dynamic List: $dynamicList");
          }

          if (dynamicList != null) {
            return dynamicList.map((item) {
              return ProductModel.fromJson(Map<String, dynamic>.from(item));
            }).toList();
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
    final jsonList = updatedList.map((item) => item.toJson()).toList();
    await _favoriteBox.put(_userId, jsonList);
    state = AsyncData(updatedList);
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
