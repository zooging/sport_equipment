// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
// import 'package:sport_equipment_rent/data/models/review.dart';
// import 'package:sport_equipment_rent/data/services/review_service.dart';
// import 'package:sport_equipment_rent/data/models/review.dart';
// import 'package:sport_equipment_rent/data/providers/review_provider.dart';
//
// class EditReviewForm extends ConsumerStatefulWidget {
//   final Review review;
//
//   const EditReviewForm({
//     super.key,
//     required this.review,
//   });
//
//   @override
//   ConsumerState<EditReviewForm> createState() => _EditReviewFormState();
// }
//
// class _EditReviewFormState extends ConsumerState<EditReviewForm> {
//   late TextEditingController _commentController;
//   late int _rating;
//   bool _isSubmitting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _commentController = TextEditingController(text: widget.review.comment);
//     _rating = widget.review.rating;
//   }
//
//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _updateReview() async {
//     setState(() => _isSubmitting = true);
//
//     try {
//       final reviewService = ref.read(reviewServiceProvider);
//       await reviewService.updateReview(
//         equipmentId: widget.review.equipmentId,
//         reviewId: widget.review.id,
//         rating: _rating,
//         comment: _commentController.text.trim(),
//       );
//
//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Отзыв обновлен')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Ошибка: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.r),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             'Редактировать отзыв',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 24.h),
//
//           // Звезды рейтинга
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(5, (index) {
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _rating = index + 1;
//                   });
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                   child: Icon(
//                     Icons.star,
//                     size: 36.r,
//                     color: index < _rating ? Colors.amber : Colors.grey[300],
//                   ),
//                 ),
//               );
//             }),
//           ),
//           SizedBox(height: 24.h),
//
//           // Поле комментария
//           TextField(
//             controller: _commentController,
//             maxLines: 3,
//             decoration: InputDecoration(
//               hintText: 'Ваш отзыв...',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//             ),
//           ),
//           SizedBox(height: 24.h),
//
//           // Кнопки
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Отмена'),
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: CustomButton(
//                   text: 'Сохранить',
//                   onPressed: _updateReview,
//                   isLoading: _isSubmitting,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
//         ],
//       ),
//     );
//   }
// }