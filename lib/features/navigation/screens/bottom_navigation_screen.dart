import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/products/providers/product_provider.dart';
import 'package:riverpod_test/features/products/screens/product_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationScreen extends ConsumerWidget {
  const BottomNavigationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final List<Widget> screens = [
      const ProductsScreen(),
      const Center(child: Text('Cart Screen (Coming Soon)')),
      const Center(
        child: Text('Profile Screen (Coming Soon)'),
      ), // Tab 2 // Tab 1
    ];
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        // ignore: deprecated_member_use
        indicatorColor: Colors.teal.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Colors.teal),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
            selectedIcon: Icon(Icons.shopping_cart, color: Colors.teal),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
