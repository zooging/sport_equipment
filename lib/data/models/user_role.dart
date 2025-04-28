enum UserRole {
  user,
  owner;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Пользователь';
      case UserRole.owner:
        return 'Владелец';
    }
  }
}