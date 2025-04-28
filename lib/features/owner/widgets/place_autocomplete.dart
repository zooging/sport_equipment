import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class PlaceAutocomplete extends StatefulWidget {
  final Function(String address) onSelected;
  final TextEditingController controller;

  const PlaceAutocomplete({
    super.key,
    required this.onSelected,
    required this.controller,
  });

  @override
  State<PlaceAutocomplete> createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<PlaceAutocomplete> {
  final _placesClient = FlutterGooglePlacesSdk('AIzaSyAzn8P8oTSpodDCtpXDZ8LxN_YUlroCJO0'); // Replace with your API key
  List<AutocompletePrediction> _predictions = [];
  bool _isLoading = false;

  Future<void> _getAddressSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _placesClient.findAutocompletePredictions(
        input,
        countries: ['ru'],
        origin: const LatLng(lat: 55.7558, lng: 37.6173), // Moscow center
        locationBias: LatLngBounds(
          southwest: const LatLng(lat: 55.5, lng: 37.3),
          northeast: const LatLng(lat: 56.0, lng: 37.9),
        ),
      );

      setState(() {
        _predictions = result.predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Autocomplete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'Введите адрес...', // Changed to Russian
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            suffixIcon: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
                : null,
          ),
          onChanged: _getAddressSuggestions,
        ),
        if (_predictions.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  title: Text(prediction.primaryText),
                  subtitle: Text(prediction.secondaryText ?? ''),
                  onTap: () {
                    final fullAddress = '${prediction.primaryText}, ${prediction.secondaryText ?? ''}';
                    widget.controller.text = fullAddress;
                    widget.onSelected(fullAddress);
                    setState(() => _predictions = []);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}