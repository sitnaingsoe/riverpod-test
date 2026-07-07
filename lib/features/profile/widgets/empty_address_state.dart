import 'package:flutter/material.dart';

class EmptyAddressState extends StatelessWidget {
  const EmptyAddressState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: Colors.grey.shade100,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please add your delivery address',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
