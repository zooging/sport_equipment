import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/data/models/location_data.dart'; // Добавлен импорт
import 'package:sport_equipment_rent/features/equipment/screens/equipment_detail_screen.dart';

class EquipmentCard extends StatelessWidget {
  final String title;
  final String address;
  final double distance;
  final double price;
  final bool isAvailable;
  final VoidCallback onTap;
  final String? imageUrl;

  const EquipmentCard({
    super.key,
    required this.title,
    required this.address,
    required this.distance,
    required this.price,
    required this.isAvailable,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EquipmentDetailScreen(
              equipment: Equipment(
                id: '1',
                title: title,
                description: 'Описание инвентаря...',
                pricePerHour: price,
                depositAmount: price * 2,
                status: isAvailable ? 'available' : 'unavailable',
                locationData: LocationData(
                  address: address,
                  latitude: 0.0,
                  longitude: 0.0,
                ),
                images: [
                  'https://example.com/image1.jpg',
                  'https://example.com/image2.jpg',
                ],
                rating: 4.5,
                reviewsCount: 12,
                category: 'Другое', // Добавляем категорию
                ownerId: 'unknown', // Добавляем ID владельца
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: imageUrl != null
                  ? Image.network(
                imageUrl!,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 120.h,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 40.sp),
              ),
            ),
            // Информация
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${distance.toStringAsFixed(1)} км',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Text(
                        '${price.toStringAsFixed(0)} ₽/час',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      isAvailable ? 'Доступно' : 'Занято',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
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