import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_test/features/cart/providers/cart_provider.dart';
import 'package:riverpod_test/features/orders/providers/orders_provider.dart';

// သင့်ရဲ့ Providers လမ်းကြောင်းများကို ဒီမှာ Import လုပ်ပါ
// import 'package:riverpod_test/features/cart/providers/cart_provider.dart';

class CheckoutBottomSheet extends ConsumerStatefulWidget {
  final double totalAmount;

  const CheckoutBottomSheet({super.key, required this.totalAmount});

  @override
  ConsumerState<CheckoutBottomSheet> createState() =>
      _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends ConsumerState<CheckoutBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _detailedAddressController = TextEditingController();

  String? _selectedRegion;

  // မြန်မာနိုင်ငံရှိ တိုင်းနှင့် ပြည်နယ်များ စာရင်း
  final List<String> _regions = [
    'Yangon',
    'Mandalay',
    'Naypyidaw',
    'Bago',
    'Sagaing',
    'Ayeyarwady',
    'Magway',
    'Tanintharyi',
    'Mon',
    'Kayin',
    'Kachin',
    'Shan',
    'Chin',
    'Rakhine',
    'Kayah',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _detailedAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cart Items များကို watch လုပ်ထားခြင်း
    final currentCartItems = ref.watch(cartProvider).value ?? [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚚 Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Delivery Details (COD)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 32),

              // 📞 Contact Information
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '09xxxxxxxxx',
                  prefixIcon: const Icon(
                    Icons.phone_android,
                    color: Colors.teal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'Please enter your phone number';
                  if (val.length < 8 || val.length > 11)
                    return 'Invalid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 📍 Delivery Address (Dropdown)
              const Text(
                'Delivery Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                hint: const Text('Select State / Region'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.map, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _regions.map((String region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                  });
                },
                validator: (val) =>
                    val == null ? 'Please select your region' : null,
              ),
              const SizedBox(height: 12),

              // Detailed Address Input
              TextFormField(
                controller: _detailedAddressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Detailed Address',
                  hintText: 'e.g., Room 4B, Building 12, Latha Township',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter your street details'
                    : null,
              ),
              const SizedBox(height: 28),

              // Total Price Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payment:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    '\$${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔙 🎯 Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: currentCartItems.isEmpty
                          ? null // Cart ထဲဘာမှမရှိရင် ခလုတ်နှိပ်မရအောင် တားဆီးခြင်း
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final fullAddress =
                                    "$_selectedRegion, ${_detailedAddressController.text}";

                                // 🚀 ၁။ Order တင်ခြင်း
                                ref
                                    .read(ordersProvider.notifier)
                                    .placeOrder(
                                      cartItems: currentCartItems,
                                      total: widget.totalAmount,
                                      address: fullAddress,
                                      phone: _phoneController.text,
                                    );

                                // 🚀 ၂။ Cart ကို ရှင်းလင်းခြင်း
                                await ref
                                    .read(cartProvider.notifier)
                                    .clearCart();

                                if (context.mounted) {
                                  Navigator.pop(
                                    context,
                                  ); // Bottom sheet ကို ပိတ်မယ်

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '🎉 Order Placed successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                      child: const Text(
                        'Confirm Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
