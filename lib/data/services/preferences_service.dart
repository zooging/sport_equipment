import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_equipment_rent/data/models/rental_sort_type.dart';

class PreferencesService {
  static const String _sortTypeKey = 'rental_sort_type';

  Future<void> saveSortType(RentalSortType sortType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortTypeKey, sortType.name);
  }

  Future<RentalSortType> getSortType() async {
    final prefs = await SharedPreferences.getInstance();
    final sortTypeName = prefs.getString(_sortTypeKey);
    return sortTypeName != null
        ? RentalSortType.values.firstWhere((e) => e.name == sortTypeName)
        : RentalSortType.newest;
  }
}