import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sport_equipment_rent/data/models/rental_history_item.dart';
import 'package:sport_equipment_rent/features/rental_history/screens/rental_detail_screen.dart';

// ...existing code...
class AnimatedRentalList extends StatelessWidget {
  final List<RentalHistoryItem> items;

  const AnimatedRentalList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: items.isEmpty
          ? _buildEmptyState()
          : _buildList(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64.r,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'Нет заказов с таким статусом',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      key: ValueKey('list_${items.length}'),
      itemCount: items.length,
      padding: EdgeInsets.all(16.r),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RentalDetailScreen(rental: item),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основная информация о бронировании
                  Row(
                    children: [
                      Icon(
                        Icons.sports,
                        size: 24.r,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          item.equipmentName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Даты и цена
                  Text(
                    'Период: ${DateFormat('dd.MM.yyyy').format(item.startDate)} - ${DateFormat('dd.MM.yyyy').format(item.endDate)}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Text(
                    'Стоимость: ${item.totalPrice.toStringAsFixed(0)} ₽',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Информация об отмене, если есть
                  if (item.status == 'rejected' && item.cancellationReason != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Причина отмены:',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            item.cancellationReason!,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          if (item.cancellationFee != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Штраф: ${item.cancellationFee!.toStringAsFixed(0)} ₽',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}