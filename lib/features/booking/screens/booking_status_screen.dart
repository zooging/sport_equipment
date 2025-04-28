import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:intl/intl.dart';

class BookingStatusScreen extends ConsumerWidget {
  final String bookingId;

  const BookingStatusScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add debug print
    print('BookingStatusScreen: bookingId = $bookingId');

    // Check if bookingId is valid
    if (bookingId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ошибка бронирования'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.r, color: Colors.red),
              SizedBox(height: 16.h),
              const Text('Некорректный ID бронирования'),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Вернуться назад'),
              ),
            ],
          ),
        ),
      );
    }

    final bookingStream = ref.watch(bookingStreamProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статус бронирования'),
      ),
      body: bookingStream.when(
        data: (booking) {
          // Handle null booking
          if (booking == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  const Text('Бронирование не найдено'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Вернуться назад'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(booking),
                SizedBox(height: 24.h),
                _buildBookingDetails(booking),
                SizedBox(height: 16.h),
                if (booking.status == 'pending' || booking.status == 'confirmed')
                  _buildActionButtons(context, ref, booking),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) {
          // Add debug print
          print('BookingStatusScreen error: $error\n$stack');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.r, color: Colors.red),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Ошибка загрузки бронирования:\n${error.toString()}',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => ref.refresh(bookingStreamProvider(bookingId)),
                  child: const Text('Попробовать снова'),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Вернуться назад'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(RentalBooking booking) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _getStatusIcon(booking.status),
            SizedBox(height: 16.h),
            Text(
              _getStatusText(booking.status),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (booking.ownerComment != null && booking.ownerComment!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                booking.ownerComment!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails(RentalBooking booking) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Детали бронирования',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              'Начало аренды:',
              DateFormat('dd.MM.yyyy HH:mm').format(booking.startDate),
            ),
            _buildDetailRow(
              'Конец аренды:',
              DateFormat('dd.MM.yyyy HH:mm').format(booking.endDate),
            ),
            _buildDetailRow(
              'Стоимость:',
              '${booking.totalPrice?.toStringAsFixed(2) ?? '0.00'} ₽',
            ),
            if (booking.equipmentId
                != null)
              _buildDetailRow(
                'Оборудование:',
                booking.equipmentId!,
              ),
            if (booking.ownerId != null)
              _buildDetailRow(
                'Владелец:',
                booking.ownerId!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, RentalBooking booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (booking.status == 'pending')
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => _showCancelConfirmationDialog(context, ref),
            child: Text(
              'Отменить',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        if (booking.status == 'confirmed')
          ElevatedButton(
            onPressed: () => _showContactOwnerDialog(context, booking),
            child: Text(
              'Связаться',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color color;

    switch (status) {
      case 'pending':
        iconData = Icons.schedule;
        color = Colors.orange;
        break;
      case 'confirmed':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 'rejected':
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case 'cancelled':
        iconData = Icons.block;
        color = Colors.grey;
        break;
      case 'completed':
        iconData = Icons.done_all;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.info;
        color = Colors.blue;
    }

    return Icon(
      iconData,
      size: 48.r,
      color: color,
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает подтверждения';
      case 'confirmed':
        return 'Подтверждено';
      case 'rejected':
        return 'Отклонено';
      case 'cancelled':
        return 'Отменено';
      case 'completed':
        return 'Завершено';
      default:
        return 'Неизвестный статус';
    }
  }

  Future<void> _showCancelConfirmationDialog(BuildContext context, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Отменить бронирование?'),
          content: const Text('Вы уверены, что хотите отменить это бронирование?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Нет'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement cancel booking logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Бронирование отменено')),
                );
              },
              child: const Text('Да, отменить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showContactOwnerDialog(BuildContext context, RentalBooking booking) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Связаться с владельцем'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (booking.ownerPhone != null)
                Text('Телефон: ${booking.ownerPhone}'),
              if (booking.ownerEmail != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text('Email: ${booking.ownerEmail}'),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}