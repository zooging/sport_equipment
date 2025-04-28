import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';
import 'package:intl/intl.dart';

class BookingCard extends ConsumerWidget {
  final RentalBooking booking;
  final bool showActions;

  const BookingCard({
    super.key,
    required this.booking,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 24.r,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy HH:mm')
                            .format(booking.startDate),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'до ${DateFormat('dd.MM.yyyy HH:mm')
                            .format(booking.endDate)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: TextStyle(
                      color: _getStatusColor(booking.status),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            if (showActions && booking.status == 'pending') ...[
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showRejectDialog(context, ref),
                    child: const Text('Отклонить'),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () => _confirmBooking(ref),
                    child: const Text('Подтвердить'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отклонить бронирование'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Причина отказа (необязательно)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final bookingService = ref.read(bookingServiceProvider);
      await bookingService.updateBookingStatus(
        booking.id,
        'rejected',
        comment: controller.text.isNotEmpty ? controller.text : null,
      );
    }
  }

  Future<void> _confirmBooking(WidgetRef ref) async {
    final bookingService = ref.read(bookingServiceProvider);
    await bookingService.updateBookingStatus(booking.id, 'confirmed');
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'confirmed':
        return 'Подтверждено';
      case 'rejected':
        return 'Отклонено';
      default:
        return 'Неизвестно';
    }
  }
}