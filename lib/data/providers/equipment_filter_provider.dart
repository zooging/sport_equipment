import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/equipment_filter.dart';

final equipmentFilterProvider = StateNotifierProvider<EquipmentFilterNotifier, EquipmentFilter>(
      (ref) => EquipmentFilterNotifier(),
);

class EquipmentFilterNotifier extends StateNotifier<EquipmentFilter> {
  EquipmentFilterNotifier() : super(EquipmentFilter());

  void updateSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void updatePriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void updateAvailability(bool? isAvailable) {
    state = state.copyWith(isAvailable: isAvailable);
  }

  void reset() {
    state = EquipmentFilter();
  }
}