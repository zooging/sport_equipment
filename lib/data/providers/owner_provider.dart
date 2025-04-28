import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/user_model.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final ownerProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists) return null;

  return UserModel.fromJson({
    'id': user.uid,
    ...doc.data()!,
  });
});