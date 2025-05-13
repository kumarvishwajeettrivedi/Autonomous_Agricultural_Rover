import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:projext/data/field_model.dart';
import 'package:projext/field_screens/fields_screen.dart';
import 'package:projext/widgets/map_card.dart';
import 'robot_control_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(FieldAdapter());
  Hive.registerAdapter(LatLngAdapter());

  // Open the fields box
  await Hive.openBox<Field>('fields');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Controller',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Controller')),
      body: Column(
        children: [
          // Map Card
          Padding(padding: const EdgeInsets.all(16.0), child: MapCard()),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FieldsListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(fontSize: 24),
                ),
                child: const Text('Open Saved fields'),
              ),
            ),
          ),
          // Robot Control Button
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RobotControlScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(fontSize: 24),
                ),
                child: const Text('Open Robot Control'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
