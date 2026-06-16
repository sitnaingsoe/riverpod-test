import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import 'package:riverpod_test/features/products/providers/product_provider.dart';
import 'package:riverpod_test/features/products/widgets/product_card.dart';
import 'dart:async';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final currentSearch = ref.watch(productSearchQueryProvider);
    final currentCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final paginationError = ref.watch(productErrorProvider);
    final isLoadMore = ref.watch(productsProvider.notifier).isLoadingMore;

    ref.listen<String>(productSearchQueryProvider, (previous, next) {
      if (previous != next) {}
    });

    ref.listen<AsyncValue<List<ProductModel>>>(productsProvider, (
      previous,
      next,
    ) {
      if (next is AsyncError && previous is AsyncData) {
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          final metrics = scrollInfo.metrics;

          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            if (!isLoadMore && paginationError == null) {
              ref.read(productsProvider.notifier).loadMoreProducts();
            }
          }
          return true;
        },
        child: Column(
          children: [
            // Search TextField Part
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
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
                          onPressed: () =>
                              ref
                                      .read(productSearchQueryProvider.notifier)
                                      .state =
                                  '',
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

            // Categories List Part
            SizedBox(
              height: 40,
              child: categoriesAsync.when(
                loading: () => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.teal,
                    ),
                  ),
                ),
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
                              ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state =
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

            // Products Grid Part
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                ),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text('No products available.'));
                  }

                  return GridView.builder(
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
                      return ProductGridItem(product: products[index]);
                    },
                  );
                },
              ),
            ),

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
                          ref
                              .read(productsProvider.notifier)
                              .loadMoreProducts();
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
      ),
    );
  }
}
