import 'package:flutter/material.dart';
import 'package:projext/full_map_screen.dart';

class MapCard extends StatelessWidget {
  MapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FullMapScreen()),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: SizedBox(
            height: 250,
            child: const Center(
              child: Icon(Icons.map, size: 50, color: Colors.green),
            ),
          ),
        ),
      ),
    );
  }
}
