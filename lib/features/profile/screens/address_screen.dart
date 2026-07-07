import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/profile/providers/address_provider.dart';
import 'package:riverpod_test/features/profile/screens/map_setup_screen.dart';
import 'package:riverpod_test/features/profile/widgets/address_card_widget.dart';
import 'package:riverpod_test/features/profile/widgets/empty_address_state.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MY Address',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: addresses.isEmpty
          ? EmptyAddressState()
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return AddressCardWidget(
                  address: address,
                  onSetDefault: () {
                    ref
                        .read(addressProvider.notifier)
                        .setDefaultAddress(address.id);
                  },
                  onDelete: () {
                    ref
                        .read(addressProvider.notifier)
                        .removeAddress(address.id);
                  },
                );
              },
            ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapSetupScreen()),
            );
          },
          label: const Text(
            "Add New Address",
            style: TextStyle(
              color: Colors.teal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
