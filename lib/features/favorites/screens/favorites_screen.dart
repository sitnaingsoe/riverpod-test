import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/favorites/providers/favorites_provider.dart';
import 'package:riverpod_test/features/products/widgets/product_card.dart'; // 💡 သင့် product_card လမ်းကြောင်း (ပုံထဲတွင် product_card.dart ဟု တွေ့ရပါသည်)

class FavoritesScreen extends ConsumerWidget {
  
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteList = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: favoriteList.isEmpty
          ? const Center(
              child: Text(
                'No favorite items yet!',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favoriteList.length,
              itemBuilder: (context, index) {
                // သင့်ရဲ့ ProductCard Widget ကို ပြန်လည်အသုံးပြုခြင်း
                return ProductGridItem(product: favoriteList[index]);
              },
            ),
    );
  }
}
