import 'package:flutter/material.dart';

class RobotControlScreen extends StatelessWidget {
  const RobotControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Robot Control Panel')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Robot Control',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Icon(Icons.construction, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text('Robot control UI to be implemented'),
          ],
        ),
      ),
    );
  }
}
