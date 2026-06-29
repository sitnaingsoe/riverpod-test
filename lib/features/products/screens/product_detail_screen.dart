import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/cart/providers/cart_provider.dart';
import 'package:riverpod_test/features/favorites/providers/favorites_provider.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import 'package:riverpod_test/features/products/providers/recommendation_notifier.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel;
    final favoritesAsync = ref.watch(favoritesProvider);
    final favoriteList = favoritesAsync.value ?? [];
    final isFavorite = favoriteList.any((item) => item.id == product.id);
    final cartNotifier = ref.read(cartProvider.notifier);
    final recommendationsAsync = ref.watch(recommendationProvider(product.id));
    final isInCart = ref
        .watch(cartProvider)
        .any((item) => item.product.id == product.id);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          product.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ၁။ Product Image Box
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[100],
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail.isNotEmpty
                        ? product.thumbnail
                        : "https://via.placeholder.com/300",
                    fit: BoxFit.cover,
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
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag လေး
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
                      const SizedBox(height: 16),

                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
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
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      recommendationsAsync.when(
                        data: (recommendedProducts) =>
                            recommendedProducts.isEmpty
                            ? const Text('No recommendations found.')
                            : SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recommendedProducts.length,
                                  itemBuilder: (context, index) {
                                    final item = recommendedProducts[index];
                                    final cartItems = ref.watch(cartProvider);
                                    final bool isInCart = cartItems.any(
                                      (cartItem) =>
                                          cartItem.product.id == item.id,
                                    );
                                    return Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        item.thumbnail,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 5,
                                                  bottom: 5,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.teal,
                                                    radius: 18,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        isInCart
                                                            ? Icons.check_circle
                                                            : Icons
                                                                  .add_shopping_cart,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: isInCart
                                                          ? null
                                                          : () {
                                                              ref
                                                                  .read(
                                                                    cartProvider
                                                                        .notifier,
                                                                  )
                                                                  .addToCart(
                                                                    item,
                                                                  );

                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).clearSnackBars();
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    '${product.title} added to cart!',
                                                                  ),
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .teal,
                                                                ),
                                                              );
                                                            },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '\$${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Text('Could not load recommendations: $err'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(product);

                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.fixed, // ✅ Full Width
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
                            cartNotifier.removeFromCart(product.id);

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
                            cartNotifier.addToCart(product);

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
      ),
    );
  }
}
