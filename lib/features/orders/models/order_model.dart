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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'shippingAddress': shippingAddress,
      'phoneNumber': phoneNumber,
      'status': status,
      'paymentMethod': paymentMethod,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate'] as String),
      shippingAddress: json['shippingAddress'] as String,
      phoneNumber: json['phoneNumber'] as String,
      status: json['status'] as String? ?? 'Pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash on Delivery',
    );
  }
}

