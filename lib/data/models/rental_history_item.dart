import 'package:cloud_firestore/cloud_firestore.dart';


class RentalHistoryItem {
  final String id;
  final String equipmentName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final String? cancellationReason;
  final double? cancellationFee;

  RentalHistoryItem({
    required this.id,
    required this.equipmentName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.cancellationReason,
    this.cancellationFee,
  });

  factory RentalHistoryItem.fromMap(Map<String, dynamic> map) {
    return RentalHistoryItem(
      id: map['id'] as String,
      equipmentName: map['equipmentName'] as String,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: map['status'] as String,
      cancellationReason: map['cancellationReason'] as String?,
      cancellationFee: (map['cancellationFee'] as num?)?.toDouble(),
    );
  }
}