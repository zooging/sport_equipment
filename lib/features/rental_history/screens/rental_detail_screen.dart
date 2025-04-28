import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sport_equipment_rent/data/models/rental_history_item.dart';
import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';


class RentalDetailScreen extends ConsumerWidget {
  final RentalHistoryItem rental;

  const RentalDetailScreen({
    super.key,
    required this.rental,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Активная';
      case 'completed':
        return 'Завершена';
      case 'cancelled':
        return 'Отменена';
      default:
        return 'Неизвестно';
    }
  }

  Future<void> _showExtendDialog(BuildContext context, WidgetRef ref) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: rental.endDate.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null && context.mounted) {
      try {
        await ref.read(bookingServiceProvider).extendBooking(
          rental.id,
          pickedDate,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аренда успешно продлена')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e')),
          );
        }
      }
    }
  }

  Future<void> _showCompleteConfirmation(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершение аренды'),
        content: const Text('Вы уверены, что хотите завершить аренду?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Завершить'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        await ref.read(bookingServiceProvider).completeBooking(rental.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аренда успешно завершена')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e')),
          );
        }
      }
    }
  }

  Future<void> _showCancelConfirmation(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    double? cancellationFee;

    try {
      // Расчет штрафа
      cancellationFee = await ref
          .read(bookingServiceProvider)
          .calculateCancellationFee(rental.id);

      if (!context.mounted) return;

      final result = await showDialog<(bool, String)>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Отмена аренды'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Штраф за отмену: ${cancellationFee?.toStringAsFixed(0) ?? '0'} ₽',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Причина отмены',
                  hintText: 'Укажите причину отмены аренды',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, (false, '')),
              child: const Text('Не отменять'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(
                context,
                (true, reasonController.text),
              ),
              child: const Text('Отменить аренду'),
            ),
          ],
        ),
      );

      if (result != null && result.$1 && context.mounted) {
        await ref.read(bookingServiceProvider).cancelBooking(
          rental.id,
          reason: result.$2,
          cancellationFee: cancellationFee ?? 0.0,  // Используем 0.0 если null
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аренда отменена')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = rental.endDate.difference(rental.startDate);
    final durationInDays = duration.inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали аренды'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус заказа
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: _getStatusColor(rental.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Text(
                    _getStatusText(rental.status),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(rental.status),
                    ),
                  ),
                  if (rental.status == 'confirmed') ...[
                    CustomButton(
                      text: 'Продлить аренду',
                      onPressed: () => _showExtendDialog(context, ref),
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text: 'Завершить аренду',
                      onPressed: () => _showCompleteConfirmation(context, ref),
                      backgroundColor: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text: 'Отменить аренду',
                      onPressed: () => _showCancelConfirmation(context, ref),
                      backgroundColor: Colors.grey[800],
                    ),
                  ],

                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Информация об инвентаре
            Text(
              'Инвентарь',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.sports,
                        size: 40.r,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rental.equipmentName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'ID заказа: ${rental.id}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Детали аренды
            Text(
              'Детали аренды',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Начало аренды',
                      DateFormat('dd.MM.yyyy HH:mm').format(rental.startDate),
                    ),
                    Divider(height: 24.h),
                    _buildDetailRow(
                      'Конец аренды',
                      DateFormat('dd.MM.yyyy HH:mm').format(rental.endDate),
                    ),
                    Divider(height: 24.h),
                    _buildDetailRow(
                      'Длительность',
                      '$durationInDays ${_getDaysText(durationInDays)}',
                    ),
                    Divider(height: 24.h),
                    _buildDetailRow(
                      'Стоимость',
                      '${rental.totalPrice.toStringAsFixed(0)} ₽',
                      valueColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            if (rental.status == 'active') ...[
              CustomButton(
                text: 'Продлить аренду',
                onPressed: () {
                  // TODO: Реализовать продление аренды
                },
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Завершить аренду',
                onPressed: () {
                  // TODO: Реализовать завершение аренды
                },
                backgroundColor: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _getDaysText(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }
}