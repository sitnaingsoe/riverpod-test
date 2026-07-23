// ignore_for_file: unused_import, unnecessary_underscores

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/cart/providers/cart_provider.dart';
import 'package:riverpod_test/features/favorites/providers/favorites_provider.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import 'package:riverpod_test/features/products/providers/product_provider.dart';
import 'package:riverpod_test/features/products/widgets/error_screen.dart';
//import 'package:riverpod_test/features/products/providers/recommendation_notifier.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalProduct =
        ModalRoute.of(context)!.settings.arguments as ProductModel;
    final productArg = ModalRoute.of(context)!.settings.arguments;
    final int productId = productArg is ProductModel
        ? productArg.id
        : productArg as int;

    final detailAsync = ref.watch(productDetailProvider(productId));

    final favoritesAsync = ref.watch(favoritesProvider);
    final favoriteList = favoritesAsync.value ?? [];
    final isFavorite = favoriteList.any((item) => item.id == productId);
    final cartNotifier = ref.read(cartProvider.notifier);
    //final recommendationsAsync = ref.watch(recommendationProvider(productId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: detailAsync.when(
          data: (product) => Text(
            product.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Product Details'),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: detailAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
        error: (err, stack) => ErrorPlaceholder(
          errorMessage:
              'Failed to load  product , Please check your connection',
          onTryAgain: () {
            ref.invalidate(productDetailProvider(productId));
          },
        ),
        data: (product) {
          final isInCart = (ref.watch(cartProvider).value ?? []).any(
            (item) => item.product.id == product.id,
          );

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ၁။ Product Image Box
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.25,
                      color: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: product.images.isNotEmpty
                            ? product.images.first
                            : "https://via.placeholder.com/300",

                        fit: BoxFit.contain,

                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.teal),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.signal_wifi_off_rounded,
                                color: Colors.grey,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Offline Mode: Image Unavailable',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.teal.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (product.discountPercentage > 0) ...[
                                // Original Price Crossed Out
                                Text(
                                  '\$${(product.price / (1 - (product.discountPercentage / 100))).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Discount Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '-${product.discountPercentage.round()}%',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(color: Colors.black12, height: 1),
                          ),

                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Product Gallery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: product.images.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        product.images[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                // Stock Status
                                Row(
                                  children: [
                                    Icon(
                                      product.stock > 0
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: product.stock > 0
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${product.availabilityStatus} (${product.stock} left)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: product.stock > 0
                                            ? Colors.green.shade700
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                // Shipping
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_shipping_outlined,
                                      color: Colors.teal,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      product.returnPolicy,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Return Policy
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment_return_outlined,
                                      color: Colors.teal,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      product.returnPolicy,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  'Customer Reviews',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (product.reviews.isEmpty)
                                  const Text('No reviews yet.')
                                else
                                  ...product.reviews.map(
                                    (review) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                review.reviewerName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: List.generate(
                                                  5,
                                                  (index) => Icon(
                                                    index < review.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            review.comment,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            review.date.substring(
                                              0,
                                              10,
                                            ), // Formatting date assuming ISO string
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(originalProduct);

                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.fixed,
                                  content: Text(
                                    isFavorite
                                        ? '${product.title} removed from favorites!'
                                        : '${product.title} added to favorites!',
                                  ),
                                  backgroundColor: isFavorite
                                      ? Colors.red.shade700
                                      : Colors.teal,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInCart
                                  ? Colors.red.shade50
                                  : Colors.teal,
                              foregroundColor: isInCart
                                  ? Colors.red.shade700
                                  : Colors.white,
                              side: isInCart
                                  ? BorderSide(color: Colors.red.shade200)
                                  : BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              if (isInCart) {
                                cartNotifier.deleteItemFromCart(
                                  originalProduct,
                                );

                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.title} removed from cart!',
                                    ),
                                    behavior: SnackBarBehavior.fixed,
                                    backgroundColor: Colors.redAccent,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                cartNotifier.addToCart(originalProduct);

                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.title} added to cart!',
                                    ),
                                    behavior: SnackBarBehavior.fixed,
                                    backgroundColor: Colors.teal,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              isInCart ? 'Remove from Cart' : 'Add to Cart',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
