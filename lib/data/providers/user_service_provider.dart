import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});