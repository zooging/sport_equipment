import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/user_role.dart';
import 'package:sport_equipment_rent/data/models/user_model.dart';
import 'package:sport_equipment_rent/data/services/cache_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    final userData = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (userData.exists) {
      _currentUser = UserModel.fromJson({
        'id': firebaseUser.uid,
        ...userData.data()!,
      });
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      // Создаем пользователя в Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Создаем документ пользователя в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Получаем дополнительные данные пользователя из Firestore
      final userData = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userData.exists) {
        throw 'Данные пользователя не найдены';
      }

      return UserModel.fromJson({
        'id': userCredential.user!.uid,
        ...userData.data()!,
      });
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            throw 'Некорректный email адрес';
          case 'user-not-found':
            throw 'Пользователь с таким email не найден';
          case 'too-many-requests':
            throw 'Слишком много попыток. Попробуйте позже';
          default:
            throw 'Ошибка сброса пароля: ${e.message}';
        }
      }
      throw 'Неизвестная ошибка: $e';
    }
  }

  Future<void> signOut() async {
    final cacheService = CacheService();
    await cacheService.clearCache();
    await _auth.signOut();
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'phone': phone,
      });

      final updatedUserData = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (updatedUserData.exists) {
        _currentUser = UserModel.fromJson({
          'id': user.uid,
          ...updatedUserData.data()!,
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }

  Future<void> updateProfilePhoto(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Создаем уникальное имя файла с timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avatar_${user.uid}_$timestamp.jpg';

      // Создаем reference для хранения
      final storageRef = _storage.ref();
      final avatarsRef = storageRef.child('user_avatars');
      final fileRef = avatarsRef.child(fileName);

      // Устанавливаем метаданные для изображения
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Загружаем файл с метаданными
      await fileRef.putFile(imageFile, metadata);

      // Получаем URL загруженного файла
      final photoUrl = await fileRef.getDownloadURL();

      // Удаляем старый аватар если он существует
      if (_currentUser?.photoUrl != null) {
        try {
          final oldAvatarRef = _storage.refFromURL(_currentUser!.photoUrl!);
          await oldAvatarRef.delete();
        } catch (e) {
          print('Error deleting old avatar: $e');
          // Продолжаем выполнение даже если не удалось удалить старый аватар
        }
      }

      // Обновляем данные в Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoUrl,
      });

      // Обновляем локальную модель пользователя
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          photoUrl: photoUrl,
          role: _currentUser!.role,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile photo: $e');
      throw Exception('Failed to update profile photo: $e');
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Обработчик ошибок аутентификации
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Пользователь с таким email уже существует';
        case 'invalid-email':
          return 'Некорректный email';
        case 'weak-password':
          return 'Пароль слишком слабый';
        case 'operation-not-allowed':
          return 'Операция не разрешена';
        case 'user-not-found':
          return 'Пользователь не найден';
        case 'wrong-password':
          return 'Неверный пароль';
        default:
          return 'Ошибка аутентификации: ${e.message}';
      }
    } else if (e is FirebaseException) {
      return 'Ошибка базы данных: ${e.message}';
    }
    return 'Неизвестная ошибка: $e';
  }
}