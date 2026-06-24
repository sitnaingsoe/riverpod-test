import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import '../services/product_service.dart';

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  return Connectivity().onConnectivityChanged;
});

class ProductNotifier extends AsyncNotifier<List<ProductModel>> {
  final _productsBox = Hive.box<ProductModel>('products_box');
  List<ProductModel> _allProducts = [];
  int _skip = 0;
  final int _limit = 10;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  @override
  Future<List<ProductModel>> build() async {
    final searchQuery = ref.watch(productSearchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile,
    );

    _skip = 0;
    _hasMoreData = true;
    _allProducts.clear();

    ref.read(productErrorProvider.notifier).state = null;

    final service = ProductService();

    try {
      if (searchQuery.isNotEmpty) {
        _allProducts = await service.searchProducts(searchQuery);
        _hasMoreData = false;
        return _allProducts;
      }

      if (selectedCategory != 'all') {
        if (!hasConnection) {
          _allProducts = _productsBox.values
              .where(
                (p) =>
                    p.category.toLowerCase() == selectedCategory.toLowerCase(),
              )
              .toList();
          _hasMoreData = false;
          return _allProducts;
        }
        _allProducts = await service.fetchProductsByCategory(selectedCategory);
        _hasMoreData = false;
        return _allProducts;
      }

      if (!hasConnection) {
        _allProducts = _productsBox.values.toList();
        _hasMoreData = _allProducts.length >= _limit;
        return _allProducts;
      }
      final initialProducts = await service.fetchProducts(
        limit: _limit,
        skip: _skip,
      );

      _allProducts.addAll(initialProducts);

      await _productsBox.clear();
      await _productsBox.addAll(initialProducts);

      if (initialProducts.length < _limit) {
        _hasMoreData = false;
      }

      return _allProducts;
    } catch (e) {
      _isLoadingMore = false;
      ref.read(productErrorProvider.notifier).state = 'Failed to sync data.';

      if (_productsBox.isNotEmpty) {
        _allProducts = _productsBox.values.toList();
        return _allProducts;
      }

      update((_) => throw e);
      return [];
    }
  }

  Future<void> loadMoreProducts() async {
    final searchQuery = ref.read(productSearchQueryProvider);
    final selectedCategory = ref.read(selectedCategoryProvider);

    if (searchQuery.isNotEmpty || selectedCategory != 'all') return;
    if (_isLoadingMore || !_hasMoreData) return;

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile,
    );

    if (!hasConnection) {
      ref.read(productErrorProvider.notifier).state =
          'Device is offline. Cannot load more.';
      return;
    }

    _isLoadingMore = true;
    ref.read(productErrorProvider.notifier).state = null;

    state = AsyncData([..._allProducts]);
    _skip += _limit;

    try {
      final service = ProductService();
      final newProducts = await service.fetchProducts(
        limit: _limit,
        skip: _skip,
      );

      if (newProducts.isEmpty) {
        _hasMoreData = false;
      } else {
        await _productsBox.addAll(newProducts);
        _allProducts.addAll(newProducts);
        if (newProducts.length < _limit) _hasMoreData = false;
      }

      _isLoadingMore = false;
      state = AsyncData([..._allProducts]);
    } catch (e) {
      _isLoadingMore = false;
      if (_skip >= _limit) _skip -= _limit;

      ref.read(productErrorProvider.notifier).state = 'No Internet Connection.';
      state = AsyncData([..._allProducts]);
    }
  }
}

final productSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final productErrorProvider = StateProvider<String?>((ref) => null);

final productsProvider =
    AsyncNotifierProvider<ProductNotifier, List<ProductModel>>(
      ProductNotifier.new,
    );

final categoriesProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  try {
    final service = ProductService();
    final apiCategories = await service.fetchCategories();
    return [
      {'slug': 'all', 'name': 'All'},
      ...apiCategories,
    ];
  } catch (e) {
    return [
      {'slug': 'all', 'name': 'All'},
    ];
  }
});

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
