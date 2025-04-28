import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';

class OwnerEquipmentService {
  final FirebaseFirestore _firestore;

  OwnerEquipmentService() : _firestore = FirebaseFirestore.instance;

  Future<void> addEquipment(Equipment equipment) async {
    try {
      await _firestore.collection('equipment').add(equipment.toJson());
    } catch (e) {
      throw 'Ошибка при добавлении оборудования: $e';
    }
  }

  Future<void> updateEquipment(Equipment equipment) async {
    try {
      await _firestore
          .collection('equipment')
          .doc(equipment.id)
          .update(equipment.toJson());
    } catch (e) {
      throw 'Ошибка при обновлении оборудования: $e';
    }
  }
}

