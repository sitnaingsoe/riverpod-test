import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_test/features/profile/models/map_location_state.dart';

class MapLocationNotifier extends AutoDisposeAsyncNotifier<MapLocationState> {
  @override
  FutureOr<MapLocationState> build() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final LatLng _defaultPosition = const LatLng(16.7761, 96.1649);
    return MapLocationState(position: _defaultPosition);
  }

  Future<void> updateLocationAndFetchAddress(LatLng newPosition) async {
    state = const AsyncLoading();
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        newPosition.latitude,
        newPosition.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String street = place.thoroughfare ?? ''; // ဥပမာ - "42nd Street"

        if (street.isEmpty) {
          street = place.name ?? '';
        }

        if (street.isEmpty || street == place.subLocality) {
          street = place.street ?? place.subLocality ?? "မသိသော နေရာ";
        }

        String city = "";

        if (place.subLocality != null &&
            place.subLocality!.isNotEmpty &&
            place.subLocality != street) {
          city += "${place.administrativeArea}, ";
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          city += "${place.administrativeArea}";
        } else if (place.administrativeArea != null) {
          city += "${place.administrativeArea}";
        }

        state = AsyncData(
          MapLocationState(
            position: newPosition,
            streetAddress: street,
            cityAddress: city,
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        MapLocationState(
          position: newPosition,
          streetAddress: "Location unfound",
          cityAddress: "",
        ),
      );
    }
  }

  Future<LatLng?> getCurrentDeviceLoaction() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'The phone location system (GPS) is turned off. Please turn it on.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'denined';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'access denined';
    }

    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    await updateLocationAndFetchAddress(currentLatLng);
    return currentLatLng;
  }
}

final mapLocationProvider =
    AsyncNotifierProvider.autoDispose<MapLocationNotifier, MapLocationState>(
      () {
        return MapLocationNotifier();
      },
    );
