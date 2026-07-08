import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/orders/models/order_model.dart';

class OrderService {
  static const String _boxName = 'orders_box';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Box get _box => Hive.box(_boxName);

  List<OrderModel> loadOrdersFromHive(String userId) {
    try {
      final dynamicList = _box.get('user_$userId') as List<dynamic>?;
      if (dynamicList == null) return [];

      return dynamicList
          .map(
            (item) =>
                OrderModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.loadOrdersFromHive error: $e');
      return [];
    }
  }

  Future<void> saveOrdersToHive(String userId, List<OrderModel> orders) async {
    try {
      final jsonList = orders.map((o) => o.toJson()).toList();
      await _box.put('user_$userId', jsonList);
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.saveOrdersToHive error: $e');
    }
  }

  Future<void> saveOrderToFirestore(String uid, OrderModel order) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('orders')
          .doc(order.id)
          .set(order.toJson());
      if (kDebugMode) print('☁️ Order ${order.id} saved to Firestore.');
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.saveOrderToFirestore error: $e');
      rethrow;
    }
  }

  Future<List<OrderModel>> syncOrdersFromFirestore(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.syncOrdersFromFirestore error: $e');
      return [];
    }
  }
}
