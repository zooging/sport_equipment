import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';


class BookingConfirmationDialog extends StatelessWidget {
  final Equipment equipment;
  final DateTime startDate;
  final DateTime endDate;
  final int hours;
  final double totalPrice;

  const BookingConfirmationDialog({
    super.key,
    required this.equipment,
    required this.startDate,
    required this.endDate,
    required this.hours,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Подтверждение бронирования'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            equipment.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'Начало аренды:',
            DateFormat('dd.MM.yyyy HH:mm').format(startDate),
          ),
          _buildInfoRow(
            'Конец аренды:',
            DateFormat('dd.MM.yyyy HH:mm').format(endDate),
          ),
          _buildInfoRow('Длительность:', '$hours ч'),
          Divider(height: 24.h),
          _buildInfoRow(
            'Стоимость аренды:',
            '$totalPrice ₽',
            isBold: true,
          ),
          _buildInfoRow(
            'Депозит:',
            '${equipment.depositAmount} ₽',
            isBold: true,
          ),
          SizedBox(height: 16.h),
          Text(
            'Депозит будет возвращен после возврата оборудования в исходном состоянии',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Отмена',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}