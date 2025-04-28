import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';

// Провайдер для стрима оборудования
final ownerEquipmentProvider = StreamProvider<List<Equipment>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('equipment')
      .where('ownerId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Equipment.fromJson({'id': doc.id, ...doc.data()}))
      .toList());
});

// Провайдер для управления оборудованием
final ownerEquipmentNotifierProvider = StateNotifierProvider<OwnerEquipmentNotifier, AsyncValue<List<Equipment>>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw 'User not authenticated';
  return OwnerEquipmentNotifier(user.uid);
});

class OwnerEquipmentNotifier extends StateNotifier<AsyncValue<List<Equipment>>> {
  final FirebaseFirestore _firestore;
  final String _ownerId;

  OwnerEquipmentNotifier(this._ownerId)
      : _firestore = FirebaseFirestore.instance,
        super(const AsyncValue.loading());

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

  Future<void> toggleAvailability(String equipmentId) async {
    try {
      final doc = await _firestore.collection('equipment').doc(equipmentId).get();
      final currentStatus = doc.data()?['status'] as String? ?? 'unavailable';
      final newStatus = currentStatus == 'available' ? 'unavailable' : 'available';

      await _firestore
          .collection('equipment')
          .doc(equipmentId)
          .update({'status': newStatus});
    } catch (e) {
      throw 'Ошибка при изменении доступности: $e';
    }
  }
}