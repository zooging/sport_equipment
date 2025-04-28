import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/features/owner/screens/manage_equipment_screen.dart';
import 'package:sport_equipment_rent/features/owner/screens/active_bookings_screen.dart';
import 'package:sport_equipment_rent/features/owner/screens/add_equipment_screen.dart';
import 'package:sport_equipment_rent/features/owner/screens/owner_profile_screen.dart';
import 'package:sport_equipment_rent/core/routes/custom_page_route.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель управления'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                CustomPageRoute(
                  child: const OwnerProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          _DashboardCard(
            icon: Icons.sports_tennis,
            title: 'Моё оборудование',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageEquipmentScreen(),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          _DashboardCard(
            icon: Icons.calendar_today,
            title: 'Активные бронирования',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActiveBookingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEquipmentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DashboardCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? equipmentId; // Добавляем опциональный ID оборудования

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.equipmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Проверяем наличие новых бронирований
    final hasNewBookings = equipmentId != null
        ? ref.watch(pendingBookingsProvider(equipmentId!)).when(
      data: (bookings) => bookings.isNotEmpty,
      loading: () => false,
      error: (_, __) => false,
    )
        : false;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 32.r,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.r,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            if (hasNewBookings)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Новые',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}