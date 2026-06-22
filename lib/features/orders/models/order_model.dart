import 'package:riverpod_test/features/cart/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final String shippingAddress;
  final String phoneNumber;
  final String status;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.shippingAddress,
    required this.phoneNumber,
    this.status = 'Pending',
    this.paymentMethod = 'Cash on Delivery',
  });
}
