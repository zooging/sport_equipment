enum RentalStatus {
  all,
  active,
  completed,
  cancelled;

  String get name {
    switch (this) {
      case RentalStatus.all:
        return 'all';
      case RentalStatus.active:
        return 'confirmed';  // Изменено с 'active' на 'confirmed'
      case RentalStatus.completed:
        return 'completed';
      case RentalStatus.cancelled:
        return 'rejected';   // Изменено с 'cancelled' на 'rejected'
    }
  }

  String get displayName {
    switch (this) {
      case RentalStatus.all:
        return 'Все';
      case RentalStatus.active:
        return 'Активные';
      case RentalStatus.completed:
        return 'Завершенные';
      case RentalStatus.cancelled:
        return 'Отмененные';
    }
  }
}