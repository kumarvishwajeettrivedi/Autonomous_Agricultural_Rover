import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projext/data/field_model.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  late GoogleMapController mapController;
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  final List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;
  bool _isLoading = true;
  LatLng? _currentPosition;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cropController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Field Title'),
              ),
              TextField(
                controller: _cropController,
                decoration: const InputDecoration(labelText: 'Crop Name'),
              ),
              TextField(
                controller: _monthsController,
                decoration: const InputDecoration(labelText: 'Months Till Sown'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _savePolygon();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePolygon() async {
    if (_polygonPoints.length < 3) return;

    final polygonId = PolygonId(_uuid.v4());
    final polygon = Polygon(
      polygonId: polygonId,
      points: _polygonPoints,
      strokeWidth: 2,
      strokeColor: Colors.green,
      fillColor: Colors.green.withOpacity(0.3),
    );

    // Create Field object
    final field = Field(
      id: _uuid.v4(),
      title: _titleController.text,
      cropName: _cropController.text,
      monthsTillSown: int.tryParse(_monthsController.text) ?? 0,
      polygonPoints: _polygonPoints,
    );

    // Save to Hive
    final box = Hive.box<Field>('fields');
    await box.add(field);

    setState(() {
      _polygons.add(polygon);
      _polygonPoints.clear();
      _markers.clear();
      _isDrawing = false;
    });

    // Clear the form
    _titleController.clear();
    _cropController.clear();
    _monthsController.clear();
  }

  void _updatePolygonVisualization() {
    if (_polygonPoints.length >= 2) {
      final tempPolygon = Polygon(
        polygonId: const PolygonId('temp_polygon'),
        points: [..._polygonPoints, _polygonPoints.first],
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.2),
      );

      setState(() {
        _polygons.removeWhere((polygon) => polygon.polygonId == const PolygonId('temp_polygon'));
        _polygons.add(tempPolygon);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initialCameraPosition = CameraPosition(
      target: _currentPosition ?? const LatLng(0, 0),
      zoom: 16,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Drawing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _polygonPoints.isNotEmpty ? _showSaveDialog : null,
          ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.satellite,
        initialCameraPosition: initialCameraPosition,
        onMapCreated: (controller) {
          mapController = controller;
          if (_currentPosition != null) {
            controller.animateCamera(
              CameraUpdate.newLatLng(_currentPosition!),
            );
          }
        },
        onTap: (LatLng point) {
          if (!_isDrawing) {
            setState(() {
              _isDrawing = true;
              _polygonPoints.clear();
              _markers.clear();
              _polygons.clear();
            });
          }
          
          setState(() {
            _polygonPoints.add(point);
            _markers.add(
              Marker(
                markerId: MarkerId('marker_${_polygonPoints.length}'),
                position: point,
                infoWindow: InfoWindow(title: 'Point ${_polygonPoints.length}'),
              ),
            );
          });
          
          _updatePolygonVisualization();
        },
        polygons: _polygons,
        markers: _markers,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isDrawing && _polygonPoints.length >= 3) {
            _showSaveDialog();
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}