import 'package:flutter/foundation.dart'; // 💡 compute သုံးရန် ထည့်သွင်းပါ
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

class ProductService {
  final Dio _dio;

  ProductService() : _dio = Dio() {
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
      'id,title,price,description,category,rating,thumbnail';

  Future<List<ProductModel>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products',
        queryParameters: {
          'limit': limit, 'skip': skip,
          'select': _productFields, // 👈 Limits data to your model fields
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

  Future<List<ProductModel>> fetchProductsByCategory(
    String categorySlug,
  ) async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products/category/$categorySlug',
        queryParameters: {'select': _productFields},
      );
      if (response.statusCode == 200) {
        return await compute(
          _parseProducts,
          response.data,
        ); // 💡 compute integration
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
}
