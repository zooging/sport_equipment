import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/services/equipment_service.dart';

final equipmentServiceProvider = Provider<EquipmentService>((ref) {
  return EquipmentService();
});