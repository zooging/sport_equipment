import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sport_equipment_rent/data/models/rental_history_item.dart';
import 'package:sport_equipment_rent/data/models/rental_status.dart';
import 'package:sport_equipment_rent/data/models/rental_sort_type.dart';
import 'package:sport_equipment_rent/features/rental_history/screens/rental_detail_screen.dart';
import 'package:sport_equipment_rent/features/rental_history/widgets/animated_rental_list.dart';
import 'package:sport_equipment_rent/data/providers/preferences_provider.dart';
import 'package:sport_equipment_rent/data/providers/rental_history_provider.dart';

class RentalHistoryScreen extends ConsumerStatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  ConsumerState<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends ConsumerState<RentalHistoryScreen> {
  RentalStatus _selectedStatus = RentalStatus.all;
  RentalSortType _sortType = RentalSortType.newest;

  @override
  void initState() {
    super.initState();
    _loadSavedSortType();
  }

  Future<void> _loadSavedSortType() async {
    try {
      final prefsService = ref.read(preferencesServiceProvider);
      final savedSortType = await prefsService.getSortType();
      if (mounted) {
        setState(() {
          _sortType = savedSortType ?? _sortType;
        });
      }
    } catch (e) {
      debugPrint('Error loading sort type: $e');
    }
  }

  Future<void> _updateSortType(RentalSortType newSortType) async {
    if (_sortType == newSortType) return;

    try {
      final prefsService = ref.read(preferencesServiceProvider);
      await prefsService.saveSortType(newSortType);
      if (mounted) {
        setState(() {
          _sortType = newSortType;
        });
      }
    } catch (e) {
      debugPrint('Error saving sort type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить настройки сортировки')),
      );
    }
  }

  List<RentalHistoryItem> _filterAndSortHistory(List<RentalHistoryItem> history) {
    var filtered = _selectedStatus == RentalStatus.all
        ? history
        : history.where((item) {
      print('Comparing item status: ${item.status} with selected: ${_selectedStatus.name}');
      return item.status == _selectedStatus.name;
    }).toList();

    filtered.sort((a, b) {
      return _sortType == RentalSortType.newest
          ? b.startDate.compareTo(a.startDate)
          : a.startDate.compareTo(b.startDate);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(rentalHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('История аренды'),
        actions: [
          PopupMenuButton<RentalSortType>(
            icon: const Icon(Icons.sort),
            onSelected: _updateSortType,
            itemBuilder: (BuildContext context) {
              return RentalSortType.values.map((RentalSortType type) {
                return PopupMenuItem<RentalSortType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type == RentalSortType.newest
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 18.r,
                        color: _sortType == type
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          color: _sortType == type
                              ? Theme.of(context).primaryColor
                              : null,
                          fontWeight: _sortType == type
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          final filteredHistory = _filterAndSortHistory(history);

          return Column(
            children: [
              // Фильтр статусов
              SizedBox(
                height: 60.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: RentalStatus.values.length,
                  itemBuilder: (context, index) {
                    final status = RentalStatus.values[index];
                    final isSelected = status == _selectedStatus;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Информация о количестве и сортировке
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Найдено: ${filteredHistory.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Сортировка: ${_sortType.displayName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Список заказов
              Expanded(
                child: filteredHistory.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64.r,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _selectedStatus == RentalStatus.all
                            ? 'История аренды пуста'
                            : 'Нет заказов с таким статусом',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
                    : AnimatedRentalList(
                  items: filteredHistory,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка загрузки: $error'),
        ),
      ),
    );
  }
}