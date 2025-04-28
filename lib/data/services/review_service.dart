import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview({
    required String equipmentId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    final reviewData = {
      'userId': userId,
      'userName': userName,
      'equipmentId': equipmentId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('equipment')
        .doc(equipmentId)
        .collection('reviews')
        .add(reviewData);

    // Обновление среднего рейтинга оборудования
    await _updateEquipmentRating(equipmentId);
  }

  Future<void> _updateEquipmentRating(String equipmentId) async {
    final reviews = await _firestore
        .collection('equipment')
        .doc(equipmentId)
        .collection('reviews')
        .get();

    if (reviews.docs.isEmpty) return;

    final totalRating = reviews.docs.fold<int>(
      0,
          (sum, doc) => sum + (doc.data()['rating'] as int),
    );

    final averageRating = totalRating / reviews.docs.length;

    await _firestore.collection('equipment').doc(equipmentId).update({
      'rating': averageRating,
      'reviewsCount': reviews.docs.length,
    });
  }

  Future<void> deleteReview(String equipmentId, String reviewId) async {
    await _firestore
        .collection('equipment')
        .doc(equipmentId)
        .collection('reviews')
        .doc(reviewId)
        .delete();

    // Обновляем средний рейтинг после удаления
    await _updateEquipmentRating(equipmentId);
  }

  bool canUserDeleteReview(String userId, Review review) {
    return userId == review.userId;
  }

  Future<void> updateReview({
    required String equipmentId,
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    await _firestore
        .collection('equipment')
        .doc(equipmentId)
        .collection('reviews')
        .doc(reviewId)
        .update({
      'rating': rating,
      'comment': comment,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _updateEquipmentRating(equipmentId);
  }

  bool canUserEditReview(String userId, Review review) {
    return userId == review.userId;
  }



  Stream<List<Review>> getUserReviews(String userId) {
    return _firestore
        .collection('equipment')
        .snapshots()
        .asyncMap((equipmentSnapshot) async {
      List<Review> allReviews = [];

      for (var equipmentDoc in equipmentSnapshot.docs) {
        final reviewsSnapshot = await equipmentDoc
            .reference
            .collection('reviews')
            .where('userId', isEqualTo: userId)
            .get();

        final equipment = equipmentDoc.data();

        for (var reviewDoc in reviewsSnapshot.docs) {
          final data = reviewDoc.data();
          allReviews.add(Review(
            id: reviewDoc.id,
            userId: data['userId'],
            userName: data['userName'],
            equipmentId: equipmentDoc.id,
            equipmentName: equipment['title'], // Добавляем название оборудования
            rating: data['rating'],
            comment: data['comment'],
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          ));
        }
      }

      // Сортируем по дате создания (новые сверху)
      allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allReviews;
    });
  }

}