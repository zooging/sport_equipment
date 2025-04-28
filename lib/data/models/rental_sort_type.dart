enum RentalSortType {
  newest,
  oldest;

  String get displayName {
    switch (this) {
      case RentalSortType.newest:
        return 'Сначала новые';
      case RentalSortType.oldest:
        return 'Сначала старые';
    }
  }
}