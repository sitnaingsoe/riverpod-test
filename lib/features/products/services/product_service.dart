import 'package:flutter/foundation.dart'; // 💡 compute သုံးရန် ထည့်သွင်းပါ
import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';

class ProductService {
  final Dio _dio;

  ProductService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
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

  // 💡 စံနှုန်းပြ static JSON parsing ဖန်ရှင်များ (Isolate ပေါ်မှာ သီးသန့် အလုပ်လုပ်ပါမည်)
  static List<ProductModel> _parseProducts(dynamic data) {
    final List<dynamic> jsonList = data['products'];
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (!hasConnection) {
      throw Exception("No Internet Connection. Device is offline.");
    }
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products',
        queryParameters: {'limit': limit, 'skip': skip},
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
        queryParameters: {'q': query},
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
