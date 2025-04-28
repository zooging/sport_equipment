import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/user_model.dart';

class RentalBooking {
  final String id;
  final String equipmentId;
  final String userId;
  final String ownerId;
  final String? ownerPhone;
  final String? ownerEmail;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String? ownerComment;

  RentalBooking({
    required this.id,
    required this.equipmentId,
    required this.userId,
    required this.ownerId,
    this.ownerPhone,
    this.ownerEmail,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.ownerComment,
  });

  factory RentalBooking.fromJson(Map<String, dynamic> json) {
    return RentalBooking(
      id: json['id'] as String,
      equipmentId: json['equipmentId'] as String,
      userId: json['userId'] as String,
      ownerId: json['ownerId'] as String,
      ownerPhone: json['ownerPhone'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ownerComment: json['ownerComment'] as String?,
    );
  }

  factory RentalBooking.fromMap(Map<String, dynamic> map) {
    return RentalBooking(
      id: map['id'] as String,
      equipmentId: map['equipmentId'] as String,
      userId: map['userId'] as String,
      ownerId: map['ownerId'] as String,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      ownerComment: map['ownerComment'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'userId': userId,
      'ownerId': ownerId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerComment': ownerComment,
    };
  }
}