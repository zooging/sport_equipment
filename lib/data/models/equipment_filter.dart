class EquipmentFilter {
  final String? searchQuery;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? isAvailable;

  EquipmentFilter({
    this.searchQuery,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.isAvailable,
  });

  EquipmentFilter copyWith({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? isAvailable,
  }) {
    return EquipmentFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}