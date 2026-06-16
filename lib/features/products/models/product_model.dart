import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(
  typeId: 0,
) // 
class ProductModel {
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

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.rating,
    required this.thumbnail,
  });

  // 💡 JSON Map ကနေ ProductModel Object အဖြစ် ပြောင်းပေးမယ့် Factory
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String,
    );
  }

  // 💡 လိုအပ်ရင် Object ကနေ JSON Map ပြန်ပြောင်းဖို့အတွက်
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
