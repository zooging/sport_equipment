import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sport_equipment_rent/data/models/review.dart';
import 'package:sport_equipment_rent/data/providers/review_provider.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  List<Review> _getMockReviews() {
    return [
      Review(
        id: 'mock1',
        userId: 'mock_user',
        userName: 'Иван Иванов',
        equipmentId: 'mock_equip1',
        equipmentName: 'Теннисные ракетки',
        rating: 5,
        comment: 'Отличное оборудование, всем рекомендую!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'mock2',
        userId: 'mock_user',
        userName: 'Иван Иванов',
        equipmentId: 'mock_equip2',
        equipmentName: 'Футбольный мяч',
        rating: 4,
        comment: 'Хорошее качество, но немного тяжеловат',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final reviewsAsync = ref.watch(userReviewsProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои отзывы'),
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          final displayReviews = reviews.isNotEmpty ? reviews : _getMockReviews();
          final isMockData = reviews.isEmpty;

          if (isMockData) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: displayReviews.length,
                    itemBuilder: (context, index) {
                      final review = displayReviews[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        color: Colors.grey[100], // Серый фон для демо-данных
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.equipmentName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      Icons.star,
                                      size: 20.r,
                                      color: index < review.rating
                                          ? Colors.amber
                                          : Colors.grey[300],
                                    );
                                  }),
                                  SizedBox(width: 8.w),
                                  Text(
                                    DateFormat('dd.MM.yyyy').format(review.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                              if (review.comment != null && review.comment!.isNotEmpty) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  review.comment!,
                                  style: TextStyle(
                                    fontStyle: isMockData ? FontStyle.italic : null,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: displayReviews.length,
            itemBuilder: (context, index) {
              final review = displayReviews[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16.h),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.equipmentName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              size: 20.r,
                              color: index < review.rating
                                  ? Colors.amber
                                  : Colors.grey[300],
                            );
                          }),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat('dd.MM.yyyy').format(review.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      if (review.comment != null && review.comment!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(review.comment!),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
    );
  }
}