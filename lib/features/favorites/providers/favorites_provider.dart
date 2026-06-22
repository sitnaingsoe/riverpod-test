import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import 'package:riverpod_test/features/profile/providers/profile_provider.dart';

const String kFavoritesBoxName = 'user_favorites_box';

class FavoritesNotifier extends Notifier<List<ProductModel>> {
  late Box _favoriteBox;
  String? _userId;
  @override
  List<ProductModel> build() {
    _favoriteBox = Hive.box(kFavoritesBoxName);
    final authState = ref.watch(profileProvider);
    return authState.maybeWhen(
      data: (user) {
        if (user != null) {
          _userId = user.id.toString();
        }
        final List<dynamic>? dynamicList = _favoriteBox.get(_userId);
        if (dynamicList != null) {
          return dynamicList.cast<ProductModel>();
        }
        return [];
      },
      orElse: () => [],
    );
  }

  void toggleFavorite(ProductModel product) {
    if (_userId == null) return;

    final isExist = state.any((item) => item.id == product.id);
    List<ProductModel> updatedList;

    if (isExist) {
      updatedList = state.where((item) => item.id != product.id).toList();
    } else {
      updatedList = [...state, product];
    }

    _favoriteBox.put(_userId, updatedList);

    state = updatedList;
  }

  bool isFavorite(int productId) {
    return state.any((item) => item.id == productId);
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<ProductModel>>(() {
      return FavoritesNotifier();
    });
