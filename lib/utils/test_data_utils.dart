import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';

class TestDataUtils {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String ownerId;

  TestDataUtils(this.ownerId);

  Future<void> addTestEquipment() async {
    final equipmentList = [
      {
        'title': 'Горный велосипед Scott Scale',
        'description': 'Профессиональный горный велосипед с карбоновой рамой, дисковыми тормозами и амортизационной вилкой. Идеально подходит для катания по пересеченной местности.',
        'pricePerHour': 500.0,
        'depositAmount': 5000.0,
        'images': [
          'https://i.imgur.com/example1.jpg', // Замените на реальные URL изображений
          'https://i.imgur.com/example2.jpg'
        ],
        'status': 'available',
        'locationData': {
          'address': 'ул. Ленина, 10, Москва',
          'latitude': 55.7558,
          'longitude': 37.6173
        },
        'ownerId': ownerId,
        'rating': 4.8,
        'reviewsCount': 12,
      },
      {
        'title': 'Сноуборд Burton Custom',
        'description': 'Универсальный сноуборд для фрирайда и фристайла. Средняя жесткость, отличная управляемость. Подходит для райдеров среднего и продвинутого уровня.',
        'pricePerHour': 800.0,
        'depositAmount': 8000.0,
        'images': [
          'https://i.imgur.com/example3.jpg', // Замените на реальные URL изображений
          'https://i.imgur.com/example4.jpg'
        ],
        'status': 'available',
        'locationData': {
          'address': 'ул. Спортивная, 5, Москва',
          'latitude': 55.7690,
          'longitude': 37.6320
        },
        'ownerId': ownerId,
        'rating': 4.9,
        'reviewsCount': 8,
      }
    ];

    final batch = _firestore.batch();

    for (var equipment in equipmentList) {
      final docRef = _firestore.collection('equipment').doc();
      batch.set(docRef, equipment);
    }

    await batch.commit();
  }
}

// Провайдер для TestDataUtils
final testDataUtilsProvider = Provider<TestDataUtils>((ref) {
  final user = ref.read(authServiceProvider).currentUser;
  if (user == null) throw Exception('User not authenticated');
  return TestDataUtils(user.uid);
});