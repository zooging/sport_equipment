import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/location_data.dart';

class Equipment {
  final String id;
  final String title;
  final String description;
  final String category;
  final double pricePerHour;
  final double depositAmount;
  final String status;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final LocationData locationData;
  final String ownerId;
  final bool isAvailable;
  final DateTime? createdAt;

  Equipment({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerHour,
    required this.depositAmount,
    required this.status,
    required this.locationData,
    required this.images,
    required this.category,
    required this.ownerId,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isAvailable = true,
    this.createdAt,

  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pricePerHour': pricePerHour,
      'depositAmount': depositAmount,
      'status': status,
      'images': images.where((url) => url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true).toList(),
      'rating': rating,
      'reviewsCount': reviewsCount,
      'locationData': locationData.toJson(),
      'category': category,
      'ownerId': ownerId,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map, String id) {
    if (id.isEmpty) {
      throw Exception('Equipment ID cannot be empty');
    }

    // Handle potentially null values with null checks and defaults
    return Equipment(
      id: id,
      title: map['title'] as String? ?? 'Без названия',
      description: map['description'] as String? ?? 'Описание отсутствует',
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (map['depositAmount'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(map['images'] as List? ?? []),
      status: map['status'] as String? ?? 'unavailable',
      locationData: LocationData.fromMap(
        (map['locationData'] as Map<String, dynamic>?) ??
            {
              'address': 'Адрес не указан',
              'latitude': 0.0,
              'longitude': 0.0,
            },
      ),
      ownerId: map['ownerId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: map['reviewsCount'] as int? ?? 0,
      category: map['category'] as String? ?? 'Другое',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'pricePerHour': pricePerHour,
      'depositAmount': depositAmount,
      'images': images,
      'status': status,
      'locationData': locationData.toMap(),
      'ownerId': ownerId,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'category': category, // Add category to map
    };
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Без названия',
      description: json['description'] as String? ?? 'Описание отсутствует',
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] as List? ?? []),
      status: json['status'] as String? ?? 'unavailable',
      locationData: LocationData.fromJson(
        (json['locationData'] as Map<String, dynamic>?) ??
            {
              'address': 'Адрес не указан',
              'latitude': 0.0,
              'longitude': 0.0,
            },
      ),
      ownerId: json['ownerId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      category: json['category'] as String? ?? 'Другое',
    );
  }


}