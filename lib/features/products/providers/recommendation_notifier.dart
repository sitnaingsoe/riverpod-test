import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:riverpod_test/features/products/models/product_model.dart';

class RecommendationNotifier
    extends FamilyAsyncNotifier<List<ProductModel>, int> {
  @override
  Future<List<ProductModel>> build(int arg) async {
    return _fetchRecommendations(arg);
  }

  Future<List<ProductModel>> _fetchRecommendations(int productId) async {
    final recUrl = Uri.parse(
      'http://192.168.100.193:8000/api/recommendations/$productId',
    );
    final recResponse = await http.get(recUrl);

    if (recResponse.statusCode != 200) {
      throw Exception('Failed to load recommendations');
    }

    final List<dynamic> recommendations = json.decode(
      recResponse.body,
    )['recommendations'];
    final List<int> idsOnly = recommendations
        .map<int>((item) => item['id'] as int)
        .toList();

    final List<Future<ProductModel>> productFutures = idsOnly.map((id) async {
      final productUrl = Uri.parse('https://dummyjson.com/products/$id');
      final productResponse = await http.get(productUrl);

      if (productResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(productResponse.body);
        return ProductModel.fromJson(data);
      } else {
        return ProductModel(
          id: id,
          title: 'Not found',
          price: 0.0,
          description: '',
          category: '',
          rating: 0.0,
          thumbnail: '',
        );
      }
    }).toList();

    return await Future.wait(productFutures);
  }
}

final recommendationProvider =
    AsyncNotifierProvider.family<
      RecommendationNotifier,
      List<ProductModel>,
      int
    >(() {
      return RecommendationNotifier();
    });
