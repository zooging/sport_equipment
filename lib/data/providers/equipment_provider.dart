import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/data/providers/equipment_filter_provider.dart';
import 'package:sport_equipment_rent/data/services/cache_service.dart';

enum SortOption {
  priceAsc,
  priceDesc,
  rating,
  newest;
  String get displayName {
    switch (this) {
      case SortOption.priceAsc:
        return 'Сначала дешевле';
      case SortOption.priceDesc:
        return 'Сначала дороже';
      case SortOption.rating:
        return 'По рейтингу';
      case SortOption.newest:
        return 'Сначала новые';
    }
  }
}

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.newest);

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final equipmentListProvider = StreamProvider<List<Equipment>>((ref) async* {
  final cacheService = ref.read(cacheServiceProvider);

  // Пробуем получить данные из кэша
  final cachedData = await cacheService.getCachedEquipment();
  if (cachedData != null) {
    yield cachedData;
  }
  // Подписываемся на обновления из Firestore
  await for (final snapshot in FirebaseFirestore.instance
      .collection('equipment')
      .snapshots()) {
    final equipment = snapshot.docs
        .map((doc) => Equipment.fromJson({'id': doc.id, ...doc.data()}))
        .toList();

    // Кэшируем новые данные
    await cacheService.cacheEquipment(equipment);

    yield equipment;
  }
});

final filteredEquipmentProvider = Provider<List<Equipment>>((ref) {
  final filter = ref.watch(equipmentFilterProvider);
  final sortOption = ref.watch(sortOptionProvider);
  final allEquipment = ref.watch(equipmentListProvider).value ?? [];

  var filtered = allEquipment.where((equipment) {
    // Search by title
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      if (!equipment.title.toLowerCase().contains(filter.searchQuery!.toLowerCase())) {
        return false;
      }
    }

    // Filter by category
    if (filter.category != null && filter.category != equipment.category) {
      return false;
    }

    // Filter by price
    if (filter.minPrice != null && equipment.pricePerHour < filter.minPrice!) {
      return false;
    }
    if (filter.maxPrice != null && equipment.pricePerHour > filter.maxPrice!) {
      return false;
    }

    // Filter by availability
    if (filter.isAvailable == true && equipment.status != 'available') {
      return false;
    }

    return true;
  }).toList();

  // Сортировка
  switch (sortOption) {
    case SortOption.priceAsc:
      filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
    case SortOption.priceDesc:
      filtered.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
    case SortOption.rating:
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    case SortOption.newest:
      filtered.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(0)) ?? 0);
  }

  return filtered;
});

final categoryListProvider = Provider<List<String>>((ref) {
  final equipment = ref.watch(equipmentListProvider).value ?? [];
  final categories = equipment
      .map((e) => e.category)
      .toSet()
      .toList();
  categories.sort();
  return categories;
});