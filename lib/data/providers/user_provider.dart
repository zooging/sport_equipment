import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/user_model.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromJson({
          'id': user.uid,
          ...doc.data()!,
        });
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});