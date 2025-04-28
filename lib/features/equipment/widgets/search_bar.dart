import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/providers/equipment_filter_provider.dart';
import 'package:sport_equipment_rent/features/equipment/widgets/filter_bottom_sheet.dart';

// Определение enum для опций сортировки
enum SortOption {
  newest(displayName: 'Новые'),
  oldest(displayName: 'Старые'),
  priceHighToLow(displayName: 'Цена ↓'),
  priceLowToHigh(displayName: 'Цена ↑'),
  popular(displayName: 'Популярные');

  const SortOption({required this.displayName});
  final String displayName;
}

// Провайдер для опций сортировки
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.newest);

class EquipmentSearchBar extends ConsumerWidget {
  const EquipmentSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortOptionProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск оборудования...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(equipmentFilterProvider.notifier).updateSearchQuery(value);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  _showFilterSheet(context, ref);
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SortOption.values.map((option) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(option.displayName),
                    selected: currentSort == option,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(sortOptionProvider.notifier).state = option;
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}