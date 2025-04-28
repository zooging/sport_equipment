import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sport_equipment_rent/data/models/location_data.dart';
import 'package:sport_equipment_rent/data/services/location_service.dart';
import 'package:sport_equipment_rent/features/owner/widgets/place_autocomplete.dart';

class LocationPickerScreen extends StatefulWidget {
  final LocationData? initialLocation;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedAddress = widget.initialLocation!.address;
      _searchController.text = widget.initialLocation!.address;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    final address = _searchController.text;
    if (address.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final locationService = LocationService();
      final location = await locationService.getLatLngFromAddress(address);
      if (location != null) {
        setState(() {
          _selectedLocation = location;
          _selectedAddress = address;
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: location,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Адрес не найден')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите местоположение'),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  LocationData(
                    latitude: _selectedLocation!.latitude,
                    longitude: _selectedLocation!.longitude,
                    address: _selectedAddress ?? 'Неизвестный адрес',
                  ),
                );
              },
              child: const Text('Готово'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: PlaceAutocomplete(
              controller: _searchController,
              onSelected: (address) => _searchLocation(),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? const LatLng(55.7558, 37.6173),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (position) async {
                    final locationService = LocationService();
                    final address = await locationService.getAddressFromLatLng(
                      position.latitude,
                      position.longitude,
                    );
                    setState(() {
                      _selectedLocation = position;
                      _selectedAddress = address;
                      _searchController.text = address;
                    });
                  },
                  markers: _selectedLocation != null
                      ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    ),
                  }
                      : {},
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}