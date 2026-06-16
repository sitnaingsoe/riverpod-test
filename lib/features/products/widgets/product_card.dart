import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 💡 ဖြေရှင်းချက် (၁) - Package ကို Import လုပ်ပါ
import 'package:riverpod_test/features/products/models/product_model.dart';

class ProductGridItem extends StatelessWidget {
  final ProductModel product;

  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.push('/product-detail', extra: product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 12,
              child: Stack(
                children: [
                  // Product Image Container
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[50],
                    padding: const EdgeInsets.all(12),
                    // 💡 ဖြေရှင်းချက် (၂) - Image.network အစား CachedNetworkImage ဖြင့် အစားထိုးပြီး Memory အား ထိန်းချုပ်ခြင်း
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.contain,

                      // 🔥 အရေးကြီးဆုံးအပိုင်း- ပုံကြီးများကို GPU Buffer ပေါ်မတင်မီ ၂၀၀x၂၀၀ အတိုင်းအတာသို့ ချုံ့ပစ်ရန် ခိုင်းစေခြင်း
                      // ဒါဆိုရင် အရှိန်ပြင်းပြင်း Scroll ဆွဲလည်း BLASTBufferQueue Error လုံးဝ မတက်တော့ပါ။
                      memCacheWidth: 200,
                      memCacheHeight: 200,

                      // ပုံစဆွဲနေစဉ် Loading ဖြစ်နေသည့်အချိန်တွင် ပြသမည့်စနစ်
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ),

                      // 💡 ဖြေရှင်းချက် (၃) - အင်တာနက်မရှိ၍ ပုံဆွဲမရပါက Layout ပျက်မသွားစေရန် ပုံရိပ်မရှိကြောင်း အစားထိုးပြသခြင်း
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button Part
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
                            color: Colors.black.withOpacity(0.1),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Title
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    // Price and Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                    // Add to Cart Button
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
                            borderRadius: BorderRadius.circular(8),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} added to cart!'),
                              duration: const Duration(seconds: 1),
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
  }
}
