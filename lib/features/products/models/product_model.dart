import 'package:hive/hive.dart';

// 1. This must match the filename exactly (e.g., if this file is favorite_model.dart)
part 'product_model.g.dart';

@HiveType(typeId: 2) // 2. Assign a unique typeId (0-223)
class ProductModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final double rating;

  @HiveField(7)
  final int stock;

  @HiveField(6)
  final String thumbnail;

  @HiveField(9)
  final double discountPercentage;
  // Fixed the constructor name to match the class
  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.rating,
    required this.thumbnail,
    this.stock = 0,
    this.discountPercentage = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      thumbnail: map['thumbnail'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      stock: map['stock']?.toInt() ?? 0,
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'rating': rating,
      'thumbnail': thumbnail,
      'stock': stock,
      'discountPercentage': discountPercentage,
    };
  }
}
