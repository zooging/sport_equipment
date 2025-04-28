import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/rental_history_item.dart';
import 'package:sport_equipment_rent/data/services/booking_service.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';

final rentalHistoryProvider = StreamProvider<List<RentalHistoryItem>>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) throw Exception('User not authenticated');

  return ref.watch(bookingServiceProvider).getUserRentalHistory(user.uid);
});