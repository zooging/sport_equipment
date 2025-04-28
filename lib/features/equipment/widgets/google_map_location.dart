import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sport_equipment_rent/data/models/location_data.dart';
import 'package:sport_equipment_rent/data/services/location_service.dart';


class EquipmentLocationMap extends StatefulWidget {
  final LocationData location;
  final String title;

  const EquipmentLocationMap({
    super.key,
    required this.location,
    required this.title,
  });

  @override
  State<EquipmentLocationMap> createState() => _EquipmentLocationMapState();
}

class _EquipmentLocationMapState extends State<EquipmentLocationMap> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  bool _isLoading = false;
  String? _routeDistance;
  String? _routeDuration;
  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _setupMarkers();
    _initializeLocation();
  }

  void _setupMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('equipment'),
        position: LatLng(
          widget.location.latitude,
          widget.location.longitude,
        ),
        infoWindow: InfoWindow(title: widget.title),
      ),
    };
  }

  Future<void> _initializeLocation() async {
    final hasPermission = await _locationService.checkPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Для работы с картой необходим доступ к геолокации'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Моё местоположение'),
          ),
        );
      });
    }
  }

  Future<void> _drawRoute() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Определение местоположения...')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final origin = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
      final destination = '${widget.location.latitude},${widget.location.longitude}';
      final apiKey = 'AIzaSyAzn8P8oTSpodDCtpXDZ8LxN_YUlroCJO0'; // Замените на ваш API ключ

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin'
            '&destination=$destination&mode=driving&key=$apiKey',
      );

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final points = PolylinePoints()
            .decodePolyline(data['routes'][0]['overview_polyline']['points']);

        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Theme.of(context).primaryColor,
          points: points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
          width: 3,
        );

        // Получаем информацию о маршруте
        final route = data['routes'][0]['legs'][0];
        setState(() {
          _polylines = {polyline};
          _routeDistance = route['distance']['text'];
          _routeDuration = route['duration']['text'];
        });

        // Подстраиваем карту под маршрут
        final bounds = LatLngBounds(
          southwest: LatLng(
            _currentPosition!.latitude < widget.location.latitude
                ? _currentPosition!.latitude
                : widget.location.latitude,
            _currentPosition!.longitude < widget.location.longitude
                ? _currentPosition!.longitude
                : widget.location.longitude,
          ),
          northeast: LatLng(
            _currentPosition!.latitude > widget.location.latitude
                ? _currentPosition!.latitude
                : widget.location.latitude,
            _currentPosition!.longitude > widget.location.longitude
                ? _currentPosition!.longitude
                : widget.location.longitude,
          ),
        );

        _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка построения маршрута: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/dir/?api=1'
        '&destination=${widget.location.latitude},${widget.location.longitude}'
        '&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.location.latitude,
                    widget.location.longitude,
                  ),
                  zoom: 15,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        if (_routeDistance != null && _routeDuration != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_routeDistance • $_routeDuration',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _drawRoute,
                icon: const Icon(Icons.directions),
                label: const Text('Построить маршрут'),
              ),
              ElevatedButton.icon(
                onPressed: _openInGoogleMaps,
                icon: const Icon(Icons.map),
                label: const Text('Открыть в Google Maps'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}