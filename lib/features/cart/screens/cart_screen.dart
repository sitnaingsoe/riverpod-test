import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/cart/providers/cart_provider.dart';
import 'package:riverpod_test/features/orders/providers/orders_provider.dart';
import 'dart:developer' as developer;

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController(text: '0993323232');
    final detailedAddressController = TextEditingController(
      text: ' Room 4B, Building 12, Mahabandoola Road, Latha Township',
    );

    final List<String> regions = [
      'Yangon',
      'Mandalay',
      'Naypyidaw',
      'Bago',
      'Sagaing',
      'Magway',
      'Ayeyarwady',
      'Thanintharyi',
      'Kachin',
      'Kayah',
      'Kayin',
      'Chin',
      'Mon',
      'Rakhine',
      'Shan',
    ];

    String? selectedRegion;
    final cartItems = ref.watch(cartProvider);
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
      body: cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 16)),
            )
          : Column(
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
                                onPressed: () => cartNotifier.updateQuantity(
                                  item.product.id,
                                  false,
                                ),
                                icon: Icon(
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
                              IconButton(
                                onPressed: () {
                                  cartNotifier.updateQuantity(
                                    item.product.id,
                                    true,
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.teal,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  cartNotifier.removeFromCart(item.product.id);
                                },
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
                    // ignore: deprecated_member_use
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
                            '\$${cartNotifier.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        onPressed: cartItems.isEmpty
                            ? null
                            : () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder:
                                          (
                                            BuildContext context,
                                            StateSetter setModalState,
                                          ) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom:
                                                    MediaQuery.of(
                                                      context,
                                                    ).viewInsets.bottom +
                                                    20,
                                                top: 24,
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Form(
                                                key: formKey,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.teal
                                                                  // ignore: deprecated_member_use
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .local_shipping,
                                                              color:
                                                                  Colors.teal,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          const Text(
                                                            'Delivery Details (COD)',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(height: 30),
                                                      const Text(
                                                        'Contact Information',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      TextFormField(
                                                        controller:
                                                            phoneController,
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        decoration: const InputDecoration(
                                                          labelText:
                                                              'Phone Number',
                                                          hintText:
                                                              '09x1axxxxxxxx',
                                                          prefixIcon: Icon(
                                                            Icons.phone_android,
                                                          ),
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                        validator: (val) {
                                                          if (val == null ||
                                                              val.isEmpty) {
                                                            return 'Please enter your phone number';
                                                          }
                                                          if (val.length < 8 ||
                                                              val.length > 11) {
                                                            return 'Please enter a valid phone number (8-11 digits)';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),

                                                      const Text(
                                                        'Delivery Address',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      DropdownButtonFormField<
                                                        String
                                                      >(
                                                        initialValue:
                                                            selectedRegion,
                                                        hint: const Text(
                                                          'Select State / Region',
                                                        ),
                                                        decoration:
                                                            const InputDecoration(
                                                              prefixIcon: Icon(
                                                                Icons.map,
                                                              ),
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                        items: regions.map((
                                                          String region,
                                                        ) {
                                                          return DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: region,
                                                            child: Text(region),
                                                          );
                                                        }).toList(),
                                                        onChanged: (newValue) {
                                                          setModalState(() {
                                                            selectedRegion =
                                                                newValue;
                                                          });
                                                        },
                                                        validator: (val) =>
                                                            val == null
                                                            ? 'Please select your region'
                                                            : null,
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),

                                                      TextFormField(
                                                        controller:
                                                            detailedAddressController,
                                                        maxLines: 3,
                                                        decoration: const InputDecoration(
                                                          labelText:
                                                              'Detailed Address',
                                                          hintText:
                                                              'e.g., Room 4B, Building 12, Mahabandoola Road, Latha Township',
                                                          alignLabelWithHint:
                                                              true,
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                        validator: (val) =>
                                                            val == null ||
                                                                val.isEmpty
                                                            ? 'Please enter your street & township details'
                                                            : null,
                                                      ),
                                                      const SizedBox(
                                                        height: 24,
                                                      ),

                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.teal,
                                                          minimumSize:
                                                              const Size(
                                                                double.infinity,
                                                                52,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          // 💡 စစ်ဆေးချက် ၁ - ခလုတ် တကယ် နှိပ်မိ/မမိ အရင်ဆုံး Log ထုတ်ကြည့်မယ်
                                                          developer.log(
                                                            '🔘 OnPressed Button Clicked!',
                                                            name: 'SHOP_DEBUG',
                                                          );

                                                          if (formKey
                                                                  .currentState ==
                                                              null) {
                                                            developer.log(
                                                              '❌ Error: formKey.currentState က null ဖြစ်နေပါတယ်!',
                                                              name:
                                                                  'SHOP_DEBUG',
                                                            );
                                                            return;
                                                          }

                                                          // 💡 စစ်ဆေးချက် ၂ - Validation အောင်မြင်လား၊ ကျရှုံးလား စစ်မယ်
                                                          final isValid =
                                                              formKey
                                                                  .currentState!
                                                                  .validate();
                                                          developer.log(
                                                            '📝 Form Validation Result: $isValid',
                                                            name: 'SHOP_DEBUG',
                                                          );

                                                          if (isValid) {
                                                            final currentCartItems =
                                                                ref.read(
                                                                  cartProvider,
                                                                );
                                                            developer.log(
                                                              '🛒 Cart Items Count to Order: ${currentCartItems.length}',
                                                              name:
                                                                  'SHOP_DEBUG',
                                                            );

                                                            if (currentCartItems
                                                                .isEmpty) {
                                                              developer.log(
                                                                '⚠️ Cart က အလွတ်ကြီးဖြစ်နေလို့ Order တင်လို့မရပါ',
                                                                name:
                                                                    'SHOP_DEBUG',
                                                              );
                                                              return;
                                                            }

                                                            final fullAddress =
                                                                "$selectedRegion, ${detailedAddressController.text}";
                                                            final totalPrice = ref
                                                                .read(
                                                                  cartProvider
                                                                      .notifier,
                                                                )
                                                                .totalPrice;

                                                            // Order လှမ်းတင်မယ်
                                                            ref
                                                                .read(
                                                                  ordersProvider
                                                                      .notifier,
                                                                )
                                                                .placeOrder(
                                                                  cartItems:
                                                                      currentCartItems,
                                                                  total:
                                                                      totalPrice,
                                                                  address:
                                                                      fullAddress,
                                                                  phone:
                                                                      phoneController
                                                                          .text,
                                                                );

                                                            Navigator.pop(
                                                              context,
                                                            );

                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  '🎉 Order Placed successfully!',
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            );

                                                            ref
                                                                .read(
                                                                  cartProvider
                                                                      .notifier,
                                                                )
                                                                .clearCart();
                                                          } else {
                                                            developer.log(
                                                              '❌ Form Validation Failed! (စာရိုက်ရမယ့် TextFields တွေထဲမှာ တစ်ခုခု လိုနေပါတယ်)',
                                                              name:
                                                                  'SHOP_DEBUG',
                                                            );
                                                          }
                                                        },
                                                        child: const Text(
                                                          'Confirm & Place Order',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    );
                                  },
                                );
                              },
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
