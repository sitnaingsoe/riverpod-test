import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_test/features/profile/models/address_model.dart';
import 'package:riverpod_test/features/profile/providers/address_provider.dart';
import 'package:riverpod_test/features/profile/providers/map_location_provider.dart';

class MapSetupScreen extends ConsumerStatefulWidget {
  const MapSetupScreen({super.key});

  @override
  ConsumerState<MapSetupScreen> createState() => _MapSetupScreenState();
}

class _MapSetupScreenState extends ConsumerState<MapSetupScreen> {
  late GoogleMapController _mapController;
  MapType _currentMapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    final locationStateAsync = ref.watch(mapLocationProvider);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(16.7761, 96.1649),
              zoom: 16.0,
            ),
            mapType: _currentMapType,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            onCameraIdle: () {
              _mapController.getVisibleRegion().then((LatLngBounds bounds) {
                LatLng centerLatLng = LatLng(
                  (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                  (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
                );

                ref
                    .read(mapLocationProvider.notifier)
                    .updateLocationAndFetchAddress(centerLatLng);
              });
            },
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Container(width: 4, height: 12, color: Colors.teal),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: PopupMenuButton<MapType>(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.layers_rounded, color: Colors.blueGrey),
              ),
              onSelected: (MapType type) =>
                  setState(() => _currentMapType = type),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: MapType.normal,
                  child: Text("Default"),
                ),
                const PopupMenuItem(
                  value: MapType.satellite,
                  child: Text("Satellite"),
                ),
                const PopupMenuItem(
                  value: MapType.terrain,
                  child: Text("Terrain"),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 240,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.pink,
              child: const Icon(Icons.my_location),
              onPressed: () async {
                try {
                  final LatLng? currentGpsPos = await ref
                      .read(mapLocationProvider.notifier)
                      .getCurrentDeviceLoaction();

                  if (currentGpsPos != null) {
                    _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: currentGpsPos, zoom: 17.0),
                      ),
                    );
                  }
                } catch (errorMessage) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⚠️ $errorMessage'),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: locationStateAsync.when(
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  ),
                ),
                error: (err, stack) => SizedBox(
                  height: 180,
                  child: Center(child: Text('Error loading location: $err')),
                ),
                data: (location) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.streetAddress,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  location.cityAddress,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Your rider will deliver to the pinned location.",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            final finalLatLong = location.position;
                            final finalAddress =
                                "${location.streetAddress}, ${location.cityAddress}";

                            _showAddressDetailsSheet(
                              context,
                              ref,
                              finalAddress,
                              finalLatLong,
                            );
                          },
                          child: const Text(
                            "Confirm Location",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressDetailsSheet(
    BuildContext context,
    WidgetRef ref,
    String googleAddress,
    LatLng latLng,
  ) {
    final mainAddressController = TextEditingController(text: googleAddress);
    final detailController = TextEditingController();
    final labelController = TextEditingController(text: 'Home');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ဘားတန်းအသေးလေး
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: mainAddressController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Pinned Location',
                prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: detailController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Building / Apartment / Street No. (Required)',
                hintText: 'e.g., No. 42, 3rd Floor, Room B',
                prefixIcon: const Icon(
                  Icons.maps_home_work_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'Save As (e.g., Home, Work, Friend\'s House)',
                prefixIcon: const Icon(
                  Icons.label_outline_rounded,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (detailController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '⚠️ Please fill in your building or street details!',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final fullCombinedAddress =
                      "${detailController.text.trim()}, $googleAddress";

                  final newAddress = AddressModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    label: labelController.text.trim(),
                    fullAddress: fullCombinedAddress,
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                    isDefault: false,
                  );

                  ref.read(addressProvider.notifier).addAddress(newAddress);

                  Navigator.pop(context);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Full Address Saved Successfully!'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                },
                child: const Text(
                  'Save Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
