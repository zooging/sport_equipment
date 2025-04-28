import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadEquipmentImage(File file) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('equipment_images/$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Ошибка загрузки изображения: $e';
    }
  }

  // Добавляем новый метод для загрузки изображений чата
  Future<String> uploadChatImage(File file) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('chat_images/$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Ошибка загрузки изображения: $e';
    }
  }
}