import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/providers/equipment_filter_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(equipmentFilterProvider);

    return Container(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Фильтры',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Категории
          DropdownButtonFormField<String>(
            value: filter.category,
            decoration: const InputDecoration(
              labelText: 'Категория',
            ),
            items: ['Лыжи', 'Сноуборды', 'Велосипеды', 'Все']
                .map((category) => DropdownMenuItem(
              value: category == 'Все' ? null : category,
              child: Text(category),
            ))
                .toList(),
            onChanged: (value) {
              ref.read(equipmentFilterProvider.notifier).updateCategory(value);
            },
          ),
          SizedBox(height: 16.h),

          // Ценовой диапазон
          Text('Ценовой диапазон'),
          RangeSlider(
            values: RangeValues(
              filter.minPrice ?? 0,
              filter.maxPrice ?? 10000,
            ),
            min: 0,
            max: 10000,
            divisions: 100,
            labels: RangeLabels(
              '${filter.minPrice?.toInt() ?? 0}₽',
              '${filter.maxPrice?.toInt() ?? 10000}₽',
            ),
            onChanged: (values) {
              ref.read(equipmentFilterProvider.notifier).updatePriceRange(
                values.start,
                values.end,
              );
            },
          ),

          // Доступность
          CheckboxListTile(
            title: const Text('Только доступное'),
            value: filter.isAvailable ?? false,
            onChanged: (value) {
              ref.read(equipmentFilterProvider.notifier).updateAvailability(value);
            },
          ),

          SizedBox(height: 16.h),

          // Кнопки
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(equipmentFilterProvider.notifier).reset();
                },
                child: const Text('Сбросить'),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Применить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}