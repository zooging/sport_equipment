import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:intl/intl.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final RentalBooking booking;
  final Function(bool, String?) onConfirm;

  const BookingConfirmationDialog({
    super.key,
    required this.booking,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return AlertDialog(
      title: const Text('Подтверждение бронирования'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Дата начала: ${DateFormat('dd.MM.yyyy HH:mm').format(booking.startDate)}'),
          Text('Дата окончания: ${DateFormat('dd.MM.yyyy HH:mm').format(booking.endDate)}'),
          Text('Стоимость: ${booking.totalPrice} ₽'),
          SizedBox(height: 16.h),
          TextField(
            controller: commentController,
            decoration: const InputDecoration(
              labelText: 'Комментарий (необязательно)',
              hintText: 'Например: Заберите оборудование по адресу...',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => onConfirm(false, commentController.text),
          child: const Text('Отклонить'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        ElevatedButton(
          onPressed: () => onConfirm(true, commentController.text),
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }
}