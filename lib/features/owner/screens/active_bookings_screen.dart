import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';
import 'package:sport_equipment_rent/data/providers/equipment_provider.dart';
import 'package:sport_equipment_rent/data/providers/user_provider.dart';
import 'package:sport_equipment_rent/data/models/user_model.dart';
import 'package:sport_equipment_rent/features/owner/widgets/booking_confirmation_dialog.dart';
import 'package:intl/intl.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:sport_equipment_rent/data/providers/equipment_service_provider.dart';
import 'package:sport_equipment_rent/data/services/user_service.dart';
import 'package:sport_equipment_rent/data/providers/user_service_provider.dart';


class ActiveBookingsScreen extends ConsumerWidget {
  const ActiveBookingsScreen({super.key});

  Future<void> _launchPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingBookings = ref.watch(ownerPendingBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Активные бронирования'),
      ),
      body: pendingBookings.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64.r,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  const Text('Нет активных бронирований'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return FutureBuilder(
                future: Future.wait([
                  ref.read(equipmentServiceProvider).getEquipmentById(booking.equipmentId),
                  ref.read(userServiceProvider).getUserById(booking.userId),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  final equipment = snapshot.data?[0];
                  final UserModel? userData = snapshot.data?[1];

                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Информация о пользователе
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20.r,
                                backgroundImage: userData?.photoUrl != null
                                    ? NetworkImage(userData!.photoUrl!)
                                    : null,
                                child: userData?.photoUrl == null
                                    ? Icon(Icons.person, size: 24.r)
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData?.name ?? 'Загрузка...',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (userData?.phone != null)
                                      Text(
                                        userData!.phone,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    Text(
                                      userData?.email ?? '',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (userData?.phone != null)
                                IconButton(
                                  icon: const Icon(Icons.phone),
                                  onPressed: () => _launchPhone(userData!.phone),
                                ),
                            ],
                          ),

                          Divider(height: 24.h),

                          // Информация об оборудовании
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              equipment?.images.isNotEmpty == true
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: Image.network(
                                  equipment!.images.first,
                                  width: 56.w,
                                  height: 56.w,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Icon(
                                Icons.sports_outlined,
                                size: 40.r,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      equipment?.title ?? 'Загрузка...',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (equipment != null)
                                      Text(
                                        '${equipment.category} • ${equipment.locationData}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Информация о бронировании
                          Text(
                            'Период аренды:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16.r, color: Colors.grey[600]),
                              SizedBox(width: 8.w),
                              Text(
                                '${DateFormat('dd.MM.yyyy HH:mm').format(booking.startDate)} - ',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text(
                                DateFormat('dd.MM.yyyy HH:mm').format(booking.endDate),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(Icons.payments_outlined, size: 16.r, color: Colors.grey[600]),
                              SizedBox(width: 8.w),
                              Text(
                                'Сумма: ${booking.totalPrice} ₽',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Кнопки действий
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await showDialog<(bool, String?)>(
                                      context: context,
                                      builder: (context) => BookingConfirmationDialog(
                                        booking: booking,
                                        onConfirm: (isConfirmed, comment) {
                                          Navigator.pop(context, (isConfirmed, comment));
                                        },
                                      ),
                                    );

                                    if (result != null && context.mounted) {
                                      final (isConfirmed, comment) = result;
                                      final bookingService = ref.read(bookingServiceProvider);

                                      try {
                                        await bookingService.updateBookingStatus(
                                          booking.id,
                                          isConfirmed ? 'confirmed' : 'rejected',
                                          comment: comment,
                                        );

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isConfirmed
                                                    ? 'Бронирование подтверждено'
                                                    : 'Бронирование отклонено',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Ошибка: $e')),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[50],
                                    foregroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 20.r),
                                      SizedBox(width: 8.w),
                                      const Text('Ответить на запрос'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
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