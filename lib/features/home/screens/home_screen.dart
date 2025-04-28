import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/features/equipment/widgets/search_bar.dart';
import 'package:sport_equipment_rent/data/providers/equipment_provider.dart';
import 'package:sport_equipment_rent/features/equipment/widgets/equipment_card.dart';
import 'package:sport_equipment_rent/features/profile/screens/profile_screen.dart';
import 'package:sport_equipment_rent/features/equipment/screens/equipment_detail_screen.dart';
import 'package:sport_equipment_rent/utils/test_data_utils.dart';
import 'package:sport_equipment_rent/data/services/equipment_service.dart';
import 'package:sport_equipment_rent/data/providers/equipment_service_provider.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> categories = [
    'Все',
    'Зимний',
    'Летний',
    'Тренажеры',
    'Водный'
  ];

  int _selectedCategoryIndex = 0;

  Future<void> _addTestEquipment() async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        throw Exception('Необходимо авторизоваться');
      }

      final equipmentService = ref.read(equipmentServiceProvider);
      await equipmentService.addTestEquipment(user.uid);

      // Обновляем список оборудования
      ref.refresh(equipmentListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тестовое оборудование добавлено')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipmentAsync = ref.watch(equipmentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Спортивный инвентарь'),
        actions: [
          // Показываем кнопку только в режиме отладки
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Добавить тестовое оборудование',
              onPressed: _addTestEquipment,
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          const EquipmentSearchBar(),

          // Категории
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                    // TODO: Обновить фильтр категорий
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Список инвентаря
          Expanded(
            child: equipmentAsync.when(
              data: (equipment) {
                final filteredEquipment = ref.watch(filteredEquipmentProvider);

                return RefreshIndicator(
                  onRefresh: () async {
                    // Обновляем список оборудования
                    return ref.refresh(equipmentListProvider);
                  },
                  child: filteredEquipment.isEmpty
                      ? ListView( // Оборачиваем в ListView для работы RefreshIndicator
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64.r,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16.h),
                              const Text('Ничего не найдено'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(), // Важно для работы RefreshIndicator
                    padding: EdgeInsets.all(16.r),
                    itemCount: filteredEquipment.length,
                    itemBuilder: (context, index) {
                      return EquipmentCard(
                        equipment: filteredEquipment[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EquipmentDetailScreen(
                                equipment: filteredEquipment[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Ошибка: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}