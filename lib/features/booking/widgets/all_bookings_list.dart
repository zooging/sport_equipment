import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:sport_equipment_rent/features/booking/widgets/booking_card.dart';
import 'package:intl/intl.dart';

class AllBookingsList extends ConsumerWidget {
  const AllBookingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(ownerBookingsProvider);

    return allBookings.when(
      data: (bookings) => bookings.isEmpty
          ? const Center(
        child: Text('Нет бронирований'),
      )
          : ListView.builder(
        itemCount: bookings.length,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            showActions: booking.status == 'pending',
          );
        },
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Ошибка: $error'),
      ),
    );
  }
}