import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/features/booking/widgets/pending_bookings_list.dart';
import 'package:sport_equipment_rent/features/booking/widgets/all_bookings_list.dart';

class OwnerBookingsScreen extends ConsumerStatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  ConsumerState<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends ConsumerState<OwnerBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление бронированиями'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ожидают'),
            Tab(text: 'Все'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingBookingsList(),
          AllBookingsList(),
        ],
      ),
    );
  }
}