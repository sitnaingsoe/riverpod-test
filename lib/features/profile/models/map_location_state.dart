import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationState {
  final LatLng position;
  final String streetAddress;
  final String cityAddress;

  MapLocationState({
    required this.position,
    this.streetAddress = "လိပ်စာရှာဖွေနေသည်...",
    this.cityAddress = "ရန်ကုန်တိုင်းဒေသကြီး",
  });

  MapLocationState copyWith({
    LatLng? position,
    String? streetAddress,
    String? cityAddress,
  }) {
    return MapLocationState(
      position: position ?? this.position,
      streetAddress: streetAddress ?? this.streetAddress,
      cityAddress: cityAddress ?? this.cityAddress,
    );
  }
}
