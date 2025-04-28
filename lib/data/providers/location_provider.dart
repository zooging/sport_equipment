import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sport_equipment_rent/data/services/location_service.dart';
import 'package:sport_equipment_rent/data/models/location_data.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider = FutureProvider<LocationData?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  final position = await locationService.getCurrentLocation();

  if (position == null) return null;

  return LocationData(
    latitude: position.latitude,
    longitude: position.longitude,
    address: '', // Можно добавить обратное геокодирование
  );
});