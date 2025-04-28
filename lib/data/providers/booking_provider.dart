import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/services/booking_service.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

final bookedDatesProvider = FutureProvider.family<List<DateTime>, String>(
      (ref, equipmentId) {
    final bookingService = ref.read(bookingServiceProvider);
    return bookingService.getBookedDates(equipmentId);
  },
);


// Добавляем новый провайдер для стрима бронирования
final bookingStreamProvider = StreamProvider.family<RentalBooking?, String>(
      (ref, bookingId) {
    if (bookingId.isEmpty) {
      throw ArgumentError('Booking ID cannot be empty');
    }


    final bookingService = ref.read(bookingServiceProvider);
    return bookingService.getBookingStream(bookingId).map((booking) {
      if (booking == null) {
        print('No booking found for ID: $bookingId');
      }
      return booking;
    });
  },
);

final ownerBookingsProvider = StreamProvider.autoDispose<List<RentalBooking>>(
      (ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) throw Exception('User not authenticated');

    final bookingService = ref.read(bookingServiceProvider);
    return bookingService.getOwnerBookings(user.uid);
  },
);

final ownerPendingBookingsProvider =
StreamProvider.autoDispose<List<RentalBooking>>(
      (ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) throw Exception('User not authenticated');

    final bookingService = ref.read(bookingServiceProvider);
    return bookingService.getOwnerPendingBookings(user.uid);
  },
);

final pendingBookingsProvider = StreamProvider.family<List<RentalBooking>, String>(
      (ref, equipmentId) {
    final bookingService = ref.read(bookingServiceProvider);
    return bookingService.getPendingBookingsForEquipment(equipmentId);
  },
);