import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/cart/providers/cart_provider.dart';
import 'package:riverpod_test/features/cart/widgets/checkout_bottom_sheet.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shopping Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: cartAsync.when(
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "သင့်ခြင်းတောင်းထဲမှာ ဘာမှမရှိသေးပါ",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final totalPrice = ref.watch(cartTotalPriceProvider);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: item.product.thumbnail,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          title: Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    cartNotifier.removeFromCart(item.product),
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.teal,
                                ),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // 👇 Quantity တိုးရန် (true)
                              IconButton(
                                onPressed: () =>
                                    cartNotifier.addToCart(item.product),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.teal,
                                ),
                              ),
                              // 👇 Item တစ်ခုလုံးကို Cart ထဲမှ ဖျက်ထုတ်ရန်
                              IconButton(
                                onPressed: () =>
                                    cartNotifier.removeFromCart(item.product),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total: ',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}', // 💡 Riverpod ကရလာတဲ့ totalPrice ကို သုံးထားပါတယ်
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Checkout Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: cartItems.isEmpty
                            ? null
                            : () {
                                // 💡 အသစ်ဆောက်ထားတဲ့ Reusable Widget ကို ဒီလိုလေးပဲ လှမ်းခေါ်လိုက်ရုံပါပဲ
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) => CheckoutBottomSheet(
                                    totalAmount: totalPrice,
                                  ),
                                );
                              },
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
        error: (error, stackTrace) =>
            Center(child: Text("❌ ချိတ်ဆက်မှု အဆင်မပြေပါ- $error")),
      ),
    );
  }
}
