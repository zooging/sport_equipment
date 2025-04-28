import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:sport_equipment_rent/features/booking/widgets/booking_card.dart';
import 'package:intl/intl.dart';

class PendingBookingsList extends ConsumerWidget {
  const PendingBookingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingBookings = ref.watch(ownerPendingBookingsProvider);

    return pendingBookings.when(
      data: (bookings) => bookings.isEmpty
          ? const Center(
        child: Text('Нет ожидающих бронирований'),
      )
          : ListView.builder(
        itemCount: bookings.length,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            showActions: true,
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