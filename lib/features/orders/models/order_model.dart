import 'package:riverpod_test/features/cart/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final String shippingAddress;
  final String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.shippingAddress,
    this.status = 'Pending',
  });
}
