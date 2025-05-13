import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:projext/data/field_model.dart';

class FieldDetailScreen extends StatefulWidget {
  final Field field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  late GoogleMapController _mapController;
  bool _isDrawingPath = false;
  final List<LatLng> _tempRoverPath = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  void _updateMapVisuals() {
    // Clear existing visuals
    _polylines.clear();
    _markers.clear();

    // Add field polygon
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('field_boundary'),
        points: widget.field.polygonPoints,
        color: Colors.green,
        width: 3,
        geodesic: true,
      ),
    );

    // Add rover path if it exists
    if (widget.field.roverPath.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('rover_path'),
          points: widget.field.roverPath,
          color: Colors.blue,
          width: 4,
          geodesic: true,
        ),
      );
    }

    setState(() {});
  }

  void _saveRoverPath() async {
    final box = Hive.box<Field>('fields');
    widget.field.roverPath = _tempRoverPath;
    await box.put(widget.field.id, widget.field);
    setState(() {
      _isDrawingPath = false;
      _tempRoverPath.clear();
    });
    _updateMapVisuals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field.title),
        actions: [
          if (_isDrawingPath)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _tempRoverPath.length >= 2 ? _saveRoverPath : null,
            ),
        ],
      ),
      body: Column(
        children: [
          // Map Section (50% of screen)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: GoogleMap(
              mapType: MapType.satellite,
              initialCameraPosition: CameraPosition(
                target:
                    widget.field.polygonPoints.isNotEmpty
                        ? widget.field.polygonPoints[0]
                        : const LatLng(0, 0),
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              polygons: {
                Polygon(
                  polygonId: const PolygonId('field'),
                  points: widget.field.polygonPoints,
                  strokeWidth: 3,
                  strokeColor: Colors.green,
                  fillColor: Colors.green.withOpacity(0.2),
                ),
              },
              polylines: _polylines,
              markers: _markers,
              onTap:
                  _isDrawingPath
                      ? (LatLng point) {
                        setState(() {
                          _tempRoverPath.add(point);
                          _markers.add(
                            Marker(
                              markerId: MarkerId(
                                'path_point_${_tempRoverPath.length}',
                              ),
                              position: point,
                              infoWindow: InfoWindow(
                                title: 'Point ${_tempRoverPath.length}',
                              ),
                            ),
                          );
                        });
                      }
                      : null,
            ),
          ),

          // Details and Controls Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Field Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.field.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text('Crop: ${widget.field.cropName}'),
                          Text(
                            'Months till sown: ${widget.field.monthsTillSown}',
                          ),
                          Text(
                            'Area points: ${widget.field.polygonPoints.length}',
                          ),
                          if (widget.field.roverPath.isNotEmpty)
                            Text(
                              'Rover path points: ${widget.field.roverPath.length}',
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Robot Selection (Placeholder)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Robot',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Choose robot'),
                            items: const [
                              DropdownMenuItem(
                                value: 'rover1',
                                child: Text('Rover 1'),
                              ),
                              DropdownMenuItem(
                                value: 'rover2',
                                child: Text('Rover 2'),
                              ),
                              DropdownMenuItem(
                                value: 'rover3',
                                child: Text('Rover 3'),
                              ),
                            ],
                            onChanged: (value) {
                              // Handle robot selection
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rover Path Controls
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rover Path',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (!_isDrawingPath)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isDrawingPath = true;
                                  _tempRoverPath.clear();
                                  _markers.clear();
                                });
                              },
                              child: const Text('Draw Rover Path'),
                            ),
                          if (_isDrawingPath)
                            Column(
                              children: [
                                Text('Points: ${_tempRoverPath.length}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isDrawingPath = false;
                                          _tempRoverPath.clear();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed:
                                          _tempRoverPath.length >= 2
                                              ? _saveRoverPath
                                              : null,
                                      child: const Text('Save Path'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
