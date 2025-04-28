import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/core/widgets/inputs/custom_text_field.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/data/models/location_data.dart';
import 'package:sport_equipment_rent/data/providers/owner_equipment_provider.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/features/equipment/widgets/google_map_location.dart';
import 'package:sport_equipment_rent/features/owner/screens/location_owner_screen.dart';
import 'package:sport_equipment_rent/data/providers/equipment_provider.dart';
import 'package:sport_equipment_rent/data/providers/equipment_service_provider.dart';

class AddEquipmentScreen extends ConsumerStatefulWidget {
  final Equipment? equipment;

  const AddEquipmentScreen({
    super.key,
    this.equipment,
  });

  @override
  ConsumerState<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends ConsumerState<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedCategory = 'Другое';
  List<String> _selectedImages = [];
  LocationData? _locationData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      _titleController.text = widget.equipment!.title;
      _descriptionController.text = widget.equipment!.description;
      _priceController.text = widget.equipment!.pricePerHour.toString();
      _depositController.text = widget.equipment!.depositAmount.toString();
      _categoryController.text = widget.equipment!.category;
      _selectedCategory = widget.equipment!.category;
      _selectedImages = widget.equipment!.images;
      _locationData = widget.equipment!.locationData;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveEquipment() async {
    if (_locationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите местоположение')),
      );
      return;
    }

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        throw Exception('Необходимо авторизоваться');
      }

      final equipmentData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'pricePerHour': double.parse(_priceController.text),
        'depositAmount': double.parse(_depositController.text),
        'category': _categoryController.text,
        'images': _selectedImages,
        'status': 'available',
        'locationData': _locationData!.toMap(),
        'rating': 0.0,
        'reviewsCount': 0,
      };

      setState(() => _isLoading = true);

      try {
        final equipmentService = ref.read(equipmentServiceProvider);
        await equipmentService.createEquipment(equipmentData, user.uid);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Оборудование успешно добавлено')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error saving equipment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipment == null
            ? 'Добавление оборудования'
            : 'Редактирование оборудования'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            CustomTextField(
              label: 'Название',
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              label: 'Описание',
              controller: _descriptionController,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите описание';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              label: 'Категория',
              controller: _categoryController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите категорию';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              label: 'Цена в час',
              controller: _priceController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите цену';
                }
                if (double.tryParse(value) == null) {
                  return 'Введите корректную цену';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              label: 'Депозит',
              controller: _depositController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите сумму депозита';
                }
                if (double.tryParse(value) == null) {
                  return 'Введите корректную сумму';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<LocationData>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPickerScreen(
                      initialLocation: _locationData,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() => _locationData = result);
                }
              },
              icon: const Icon(Icons.location_on),
              label: Text(_locationData != null
                  ? 'Изменить местоположение'
                  : 'Выбрать местоположение'),
            ),
            if (_locationData != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Адрес: ${_locationData!.address}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ],

            if (_locationData != null)
              EquipmentLocationMap(
                location: _locationData!,
                title: _titleController.text,
              ),

            SizedBox(height: 24.h),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveEquipment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}