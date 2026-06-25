import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/favorites/providers/favorites_provider.dart';
import 'package:riverpod_test/features/products/widgets/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ၁။ Async အခြေအနေကို Watch လုပ်မည်
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: favoritesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),

        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),

        data: (favoriteList) {
          if (favoriteList.isEmpty) {
            return const Center(
              child: Text(
                'No favorite items yet!',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: favoriteList.length,
            itemBuilder: (context, index) {
              final reverseIndex = favoriteList.length - 1 - index;
              return ProductGridItem(product: favoriteList[reverseIndex]);
            },
          );
        },
      ),
    );
  }
}
