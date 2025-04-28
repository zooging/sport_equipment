import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';

class EquipmentListItem extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onEdit;
  final VoidCallback onToggleAvailability;

  const EquipmentListItem({
    super.key,
    required this.equipment,
    required this.onEdit,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListTile(
        leading: equipment.images.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.network(
            equipment.images.first,
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
        title: Text(equipment.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${equipment.pricePerHour} ₽/час'),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12.r,
                  color: equipment.status == 'available'
                      ? Colors.green
                      : Colors.red,
                ),
                SizedBox(width: 4.w),
                Text(
                  equipment.status == 'available'
                      ? 'Доступно'
                      : 'Недоступно',
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onEdit,
              child: const Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Редактировать'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onToggleAvailability,
              child: Row(
                children: [
                  Icon(
                    equipment.status == 'available'
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    equipment.status == 'available'
                        ? 'Сделать недоступным'
                        : 'Сделать доступным',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}