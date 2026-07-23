import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_test/features/products/models/product_detail_model.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

class ProductService {
  final Dio _dio;

  ProductService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://dummyjson.com',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  static List<ProductModel> _parseProducts(dynamic data) {
    final List<dynamic> jsonList = data['products'];
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  final String _productFields =
      'id,title,price,description,category,rating,thumbnail,stock,discountPercentage';

  Future<List<ProductModel>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products',
        queryParameters: {
          'limit': limit,
          'skip': skip,
          'select': _productFields,
        },
      );

      if (response.statusCode == 200) {
        return await compute(_parseProducts, response.data);
      } else {
        throw Exception('Failed to fetch products');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('No Internet Connection. Device is offline.');
      }
      throw Exception(e.response?.data['message'] ?? 'Server Error');
    } catch (e) {
      throw Exception('Connection lost. Please try again.');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products/search',
        queryParameters: {'q': query, 'select': _productFields},
      );
      if (response.statusCode == 200) {
        return await compute(
          _parseProducts,
          response.data,
        ); // 💡 compute integration
      }
      throw Exception('Failed to search products');
    } catch (e) {
      throw 'Search failed. Please check network.';
    }
  }

  Future<List<ProductModel>> fetchProductsByCategory({
    required String categorySlug,
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products/category/$categorySlug',
        queryParameters: {
          'limit': limit,
          'skip': skip,
          'select': _productFields,
        },
      );
      if (response.statusCode == 200) {
        return await compute(_parseProducts, response.data);
      }
      throw Exception('Fail to load products by category');
    } catch (e) {
      throw 'Failed to load category products.';
    }
  }

  Future<List<Map<String, String>>> fetchCategories() async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products/categories',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map(
              (item) => {
                'slug': item['slug'] as String,
                'name': item['name'] as String,
              },
            )
            .toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      throw 'Category Fetch Error';
    }
  }

  Future<List<int>> fetchRecommendations(int productId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/recommendations/$productId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<int>.from(data['recommendations']);
    }
    return [];
  }

  Future<ProductDetailModel> fetchProductDetail(int productId) async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products/$productId',
      );
      if (response.statusCode == 200) {
        return ProductDetailModel.fromJson(response.data);
      }
      throw Exception('Failed to load product details');
    } catch (e) {
      throw Exception('Error fetching details: $e');
    }
  }
}
