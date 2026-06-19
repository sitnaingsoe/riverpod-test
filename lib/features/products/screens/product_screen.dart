import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/cart/providers/cart_provider.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import 'package:riverpod_test/features/products/providers/product_provider.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_test/features/products/widgets/product_skeleton.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentSearch = ref.read(productSearchQueryProvider);
    final currentCategory = ref.read(selectedCategoryProvider);
    final paginationError = ref.read(productErrorProvider);
    final notifier = ref.read(productsProvider.notifier);

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (currentSearch.isNotEmpty || currentCategory != 'all') return;

      if (notifier.isLoadingMore ||
          paginationError != null ||
          !notifier.hasMoreData) {
        return;
      }

      notifier.loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final currentSearch = ref.watch(productSearchQueryProvider);
    final currentCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final paginationError = ref.watch(productErrorProvider);

    final isLoadMore = ref.watch(productsProvider).isLoading
        ? false
        : ref.read(productsProvider.notifier).isLoadingMore;

    // 💡 အဓိကပြင်ဆင်ချက်- အင်တာနက် အခြေအနေပြောင်းလဲမှုကို နားထောင်ခြင်း
    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityStreamProvider,
      (previous, next) {
        if (next.hasValue) {
          final results = next.value!;
          final hasConnection = results.any(
            (result) =>
                result == ConnectivityResult.wifi ||
                result == ConnectivityResult.mobile,
          );

          // အင်တာနက် ပြန်ပွင့်လာပြီး လက်ရှိ screen မှာ error ပြနေလျှင်
          if (hasConnection && paginationError != null) {
            ref.read(productErrorProvider.notifier).state =
                null; // Error Panel ပိတ်မည်
          }
        }
      },
    );

    // SnackBar Listener (မူလအတိုင်း ထားပါသည်)
    ref.listen<AsyncValue<List<ProductModel>>>(productsProvider, (
      previous,
      next,
    ) {
      if (next.hasError && !next.isLoading && previous?.hasValue == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(next.error.toString())),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Store Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  ref.read(productSearchQueryProvider.notifier).state = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products by title...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: currentSearch.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(productSearchQueryProvider.notifier).state =
                              '';
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 40,
            child: categoriesAsync.when(
              loading: () => const CategorySkeleton(),
              error: (err, stack) => const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text('Error loading categories'),
              ),
              data: (categoriesList) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    final category = categoriesList[index];
                    final slug = category['slug']!;
                    final name = category['name']!;
                    final isSelected = currentCategory == slug;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(name),
                        selected: isSelected,
                        selectedColor: Colors.teal,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                slug;
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: productsAsync.when(
              skipLoadingOnRefresh: false,
              loading: () => const ProductGridSkeleton(),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }

                return RefreshIndicator(
                  color: Colors.teal, // Loading စက်ဝိုင်းအရောင်
                  onRefresh: () async {
                    // 🔥 ၂။ ဒေတာအသစ် ပြန်ဆွဲရန်အတွက် Provider ကို refresh/invalidate လုပ်ခြင်း
                    ref.invalidate(productsProvider);

                    ref.invalidate(categoriesProvider);

                    try {
                      await ref.read(productsProvider.future);
                    } catch (_) {}
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () =>
                              context.push('/product-detail', extra: product),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 12,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.grey[50],
                                      padding: const EdgeInsets.all(12),
                                      child: CachedNetworkImage(
                                        imageUrl: product.thumbnail,
                                        fit: BoxFit.contain,
                                        memCacheWidth: 200,
                                        memCacheHeight: 200,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Colors.grey[100],
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.teal,
                                                      ),
                                                ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Colors.grey[100],
                                              child: const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // ignore: deprecated_member_use
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              // ignore: deprecated_member_use
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                          icon: const Icon(
                                            Icons.favorite_border,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 9,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${product.rating}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 36,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Add to Cart',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .addToCart(product);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${product.title} added to cart!',
                                                ),
                                                backgroundColor: Colors.teal,
                                                duration: const Duration(
                                                  seconds: 1,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Pagination Error Panel
          if (paginationError != null)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.red[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          paginationError,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ref.read(productErrorProvider.notifier).state = null;
                        ref.read(productsProvider.notifier).loadMoreProducts();
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: Colors.teal,
                      ),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (isLoadMore)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.white,
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading more products ...',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
