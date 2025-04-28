import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';

class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Создание нового оборудования
  Future<String> createEquipment(Map<String, dynamic> equipmentData, String ownerId) async {
    try {
      // Проверяем наличие владельца
      if (ownerId.isEmpty) {
        throw Exception('ID владельца не может быть пустым');
      }

      // Добавляем ID владельца к данным оборудования
      equipmentData['ownerId'] = ownerId;

      // Создаем новый документ и получаем его ID
      final docRef = _firestore.collection('equipment').doc();
      await docRef.set(equipmentData);

      print('Created equipment with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating equipment: $e');
      throw Exception('Failed to create equipment: $e');
    }
  }
  // Получение списка всего оборудования
  Stream<List<Equipment>> getAllEquipment() {
    return _firestore
        .collection('equipment')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Equipment.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Получение оборудования по ID
  Future<Equipment?> getEquipmentById(String id) async {
    try {
      final doc = await _firestore.collection('equipment').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Equipment.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting equipment: $e');
      return null;
    }
  }

  // Обновление статуса оборудования
  Future<void> updateEquipmentStatus(String equipmentId, String status) async {
    try {
      await _firestore
          .collection('equipment')
          .doc(equipmentId)
          .update({'status': status});
    } catch (e) {
      print('Error updating equipment status: $e');
      throw Exception('Failed to update equipment status: $e');
    }
  }

  // Добавление тестового оборудования
  Future<void> addTestEquipment(String ownerId) async {
    final testEquipment = [
      {
        'title': 'Горный велосипед Scott Scale',
        'description': 'Профессиональный горный велосипед с карбоновой рамой.',
        'pricePerHour': 500.0,
        'depositAmount': 5000.0,
        'images': [
          'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?q=80&w=1722&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'https://images.unsplash.com/photo-1559348349-86f1f65817fe?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
        ],
        'status': 'available',
        'locationData': {
          'address': 'ул. Ленина, 10, Москва',
          'latitude': 55.7558,
          'longitude': 37.6173
        },
        'rating': 4.8,
        'reviewsCount': 12,
        'category': 'Летний',
      },
      {
        'title': 'Сноуборд Burton Custom',
        'description': 'Универсальный сноуборд для фрирайда и фристайла.',
        'pricePerHour': 800.0,
        'depositAmount': 8000.0,
        'images': [
          'https://i.imgur.com/snow1.jpg',
          'https://i.imgur.com/snow2.jpg'
        ],
        'status': 'available',
        'locationData': {
          'address': 'ул. Спортивная, 5, Москва',
          'latitude': 55.7690,
          'longitude': 37.6320
        },
        'rating': 4.9,
        'reviewsCount': 8,
        'category': 'Зимний',
      }
    ];

    // Передаем оба аргумента: данные оборудования и ID владельца
    for (var equipment in testEquipment) {
      await createEquipment(equipment, ownerId);
    }
  }
}