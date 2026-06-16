import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import '../services/product_service.dart';

class ProductNotifier extends AsyncNotifier<List<ProductModel>> {
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

    _skip = 0;
    _hasMoreData = true;
    _allProducts.clear();

    final service = ProductService();

    try {
      if (searchQuery.isNotEmpty) {
        _allProducts = await service.searchProducts(searchQuery);
        _hasMoreData = false;
        return _allProducts;
      }

      if (selectedCategory != 'all') {
        _allProducts = await service.fetchProductsByCategory(selectedCategory);
        _hasMoreData = false;
        return _allProducts;
      }

      final initialProducts = await service.fetchProducts(
        limit: _limit,
        skip: _skip,
      );
      _allProducts.addAll(initialProducts);

      if (initialProducts.length < _limit) {
        _hasMoreData = false;
      }

      return _allProducts;
    } catch (e) {
      _isLoadingMore = false;
      _skip -= _limit;
      state = AsyncData([..._allProducts]); // 👈 ပြဿနာက ဒီနေရာပါ!
      ref.read(productErrorProvider.notifier).state = '...';
      return _allProducts;
    }
  }

  Future<void> loadMoreProducts() async {
    final searchQuery = ref.read(productSearchQueryProvider);
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (searchQuery.isNotEmpty || selectedCategory != 'all') return;

    if (_isLoadingMore ||
        !_hasMoreData ||
        ref.read(productErrorProvider) != null)
      return;

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
        _allProducts.addAll(newProducts);
        if (newProducts.length < _limit) _hasMoreData = false;
      }

      _isLoadingMore = false;
      state = AsyncData([..._allProducts]);
    } catch (e, stack) {
      _isLoadingMore = false;

      if (_skip >= _limit) {
        _skip -= _limit;
      }
      ref.read(productErrorProvider.notifier).state = 'No Internet Connection.';
      state = AsyncError(e.toString(), stack);
    }
  }
}

// ---------------- Providers ----------------
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
  final service = ProductService();
  final apiCategories = await service.fetchCategories();

  return [
    {'slug': 'all', 'name': 'All'},
    ...apiCategories,
  ];
});
