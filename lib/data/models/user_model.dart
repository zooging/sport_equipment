import 'package:sport_equipment_rent/data/models/user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? photoUrl;
  final UserRole role;

  String get uid => id;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
      role: UserRole.values.firstWhere(
            (role) => role.name == (json['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.name,
    };
  }
}