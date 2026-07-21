import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test/features/cart/models/cart_item_model.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

void main() {
  group('CartItemModel Tests', () {
    test('toJson should correctly convert the model into a Map', () {
      final fakeProduct = ProductModel(
        id: 1,
        title: 'Test Product',
        price: 99.99,
        description: 'A product for testing',
        category: 'Test Category',
        rating: 0,
        thumbnail: 'https://test.image.com/img.png',
      );

      final cartItem = CartItemModel(product: fakeProduct, quantity: 2);

      // 2. Act: သင့်ရဲ့ တကယ့် toJson() method ကို ခေါ်သုံးပါ
      final resultMap = cartItem.toJson();

      // 3. Assert: map ထဲတွင် မှန်ကန်သော တန်ဖိုးများ ရှိမရှိ စစ်ဆေးပါ
      expect(resultMap['quantity'], 2);
      expect(resultMap['product']['id'], 1);
      expect(resultMap['product']['title'], 'Test Product');
    });
  });
}
