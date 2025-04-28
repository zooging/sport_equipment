// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
// import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
// import 'package:sport_equipment_rent/data/providers/review_provider.dart';
//
// class ReviewForm extends ConsumerStatefulWidget {
//   final String equipmentId;
//   final Function() onReviewSubmitted;
//
//   const ReviewForm({
//     super.key,
//     required this.equipmentId,
//     required this.onReviewSubmitted,
//   });
//
//   @override
//   ConsumerState<ReviewForm> createState() => _ReviewFormState();
// }
//
// class _ReviewFormState extends ConsumerState<ReviewForm> {
//   final _commentController = TextEditingController();
//   int _rating = 0;
//   bool _isSubmitting = false;
//
//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submitReview() async {
//     if (_rating == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Пожалуйста, поставьте оценку')),
//       );
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       final user = ref.read(authServiceProvider).currentUser;
//       if (user == null) throw Exception('Пользователь не авторизован');
//
//       final reviewService = ref.read(reviewServiceProvider);
//       await reviewService.addReview(
//         equipmentId: widget.equipmentId,
//         userId: user.uid,
//         userName: user.name ?? 'Пользователь',
//         rating: _rating,
//         comment: _commentController.text.trim(),
//       );
//
//       if (mounted) {
//         widget.onReviewSubmitted();
//         Navigator.of(context).pop();
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
//             'Оставить отзыв',
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
//               hintText: 'Напишите ваш отзыв...',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//             ),
//           ),
//           SizedBox(height: 24.h),
//
//           // Кнопка отправки
//           CustomButton(
//             text: 'Отправить отзыв',
//             onPressed: _submitReview,
//             isLoading: _isSubmitting,
//           ),
//           SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
//         ],
//       ),
//     );
//   }
// }