import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'field_model.g.dart'; // Must match the file name

@HiveType(typeId: 0)
class Field {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String cropName;
  
  @HiveField(3)
  final int monthsTillSown;
  
  @HiveField(4)
  final List<LatLng> polygonPoints;
  
  @HiveField(5)
  List<LatLng> roverPath;

  Field({
    required this.id,
    required this.title,
    required this.cropName,
    required this.monthsTillSown,
    required this.polygonPoints,
    this.roverPath = const [],
  });
}
// Helper extension to convert LatLng to/from Hive
extension LatLngExtension on LatLng {
  List<double> toList() => [latitude, longitude];
}

class LatLngAdapter extends TypeAdapter<LatLng> {
  @override
  final typeId = 1;

  @override
  LatLng read(BinaryReader reader) {
    final list = reader.read() as List<double>;
    return LatLng(list[0], list[1]);
  }

  @override
  void write(BinaryWriter writer, LatLng obj) {
    writer.write(obj.toList());
  }
}
