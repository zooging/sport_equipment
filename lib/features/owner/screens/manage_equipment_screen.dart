import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/features/owner/widgets/equipment_list_item.dart';
import 'package:sport_equipment_rent/features/owner/screens/add_equipment_screen.dart';
import 'package:sport_equipment_rent/data/providers/owner_equipment_provider.dart';

class ManageEquipmentScreen extends ConsumerStatefulWidget {
  const ManageEquipmentScreen({super.key});

  @override
  ConsumerState<ManageEquipmentScreen> createState() => _ManageEquipmentScreenState();
}

class _ManageEquipmentScreenState extends ConsumerState<ManageEquipmentScreen> {
  Future<void> _toggleAvailability(Equipment equipment) async {
    try {
      await ref.read(ownerEquipmentNotifierProvider.notifier).toggleAvailability(equipment.id);
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
    final ownerEquipment = ref.watch(ownerEquipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление оборудованием'),
      ),
      body: ownerEquipment.when(
        data: (equipment) {
          if (equipment.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_outlined,
                    size: 64.r,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  const Text('У вас пока нет оборудования'),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddEquipment(),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить оборудование'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: equipment.length,
            itemBuilder: (context, index) {
              return EquipmentListItem(
                equipment: equipment[index],
                onEdit: () => _navigateToEditEquipment(equipment[index]),
                onToggleAvailability: () => _toggleAvailability(equipment[index]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEquipment,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddEquipment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEquipmentScreen(),
      ),
    );
  }

  void _navigateToEditEquipment(Equipment equipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEquipmentScreen(equipment: equipment),
      ),
    );
  }
}