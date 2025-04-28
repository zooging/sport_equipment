import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/review.dart';
import 'package:sport_equipment_rent/data/services/review_service.dart';

// Провайдер для сервиса отзывов
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

// Провайдер для получения отзывов пользователя
final userReviewsProvider = StreamProvider.family<List<Review>, String>((ref, userId) {
  final reviewService = ref.read(reviewServiceProvider);
  return reviewService.getUserReviews(userId);
});