import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_equipment_rent/data/models/location_data.dart';
import 'package:sport_equipment_rent/data/models/rental_sort_type.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static const String _sortTypeKey = 'rental_sort_type';

  // Проверка разрешений
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print('Ошибка поиска координат: $e');
      return null;
    }
  }

  // Получение текущей локации
  Future<Position?> getCurrentLocation() async {
    if (!await checkPermission()) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  // Расчет расстояния
  double calculateDistance(LocationData start, LocationData end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Форматирование расстояния
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} м';
    }
    return '${(meters / 1000).toStringAsFixed(1)} км';
  }

  // Сохранение типа сортировки
  Future<void> saveSortType(RentalSortType sortType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortTypeKey, sortType.name);
  }

  // Получение типа сортировки
  Future<RentalSortType> getSortType() async {
    final prefs = await SharedPreferences.getInstance();
    final sortTypeName = prefs.getString(_sortTypeKey);
    return sortTypeName != null
        ? RentalSortType.values.firstWhere((e) => e.name == sortTypeName)
        : RentalSortType.newest;
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}';
      }
      return 'Адрес не найден';
    } catch (e) {
      return 'Ошибка получения адреса';
    }
  }

}