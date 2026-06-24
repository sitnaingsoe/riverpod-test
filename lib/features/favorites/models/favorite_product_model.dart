import 'package:hive/hive.dart';

// 1. This must match the filename exactly (e.g., if this file is favorite_model.dart)
part 'favorite_product_model.g.dart';

@HiveType(typeId: 3) // 2. Assign a unique typeId (0-223)
class FavoriteModel extends HiveObject {
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

  @HiveField(6)
  final String thumbnail;

  // Fixed the constructor name to match the class
  FavoriteModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.rating,
    required this.thumbnail,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String,
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
    };
  }
}
