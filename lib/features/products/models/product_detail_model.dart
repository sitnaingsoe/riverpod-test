class ProductDetailModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String availabilityStatus;
  final String returnPolicy;
  final List<String> images;
  final List<ReviewModel> reviews;

  ProductDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.availabilityStatus,
    required this.returnPolicy,
    required this.images,
    required this.reviews,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      brand: json['brand'] ?? 'Unknown Brand',
      availabilityStatus: json['availabilityStatus'] ?? '',
      returnPolicy: json['returnPolicy'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReviewModel {
  final int rating;
  final String comment;
  final String reviewerName;
  final String date;

  ReviewModel({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
