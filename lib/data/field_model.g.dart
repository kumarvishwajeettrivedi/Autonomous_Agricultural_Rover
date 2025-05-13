// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FieldAdapter extends TypeAdapter<Field> {
  @override
  final int typeId = 0;

  @override
  Field read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Field(
      id: fields[0] as String,
      title: fields[1] as String,
      cropName: fields[2] as String,
      monthsTillSown: fields[3] as int,
      polygonPoints: (fields[4] as List).cast<LatLng>(),
      roverPath: (fields[5] as List).cast<LatLng>(),
    );
  }

  @override
  void write(BinaryWriter writer, Field obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.cropName)
      ..writeByte(3)
      ..write(obj.monthsTillSown)
      ..writeByte(4)
      ..write(obj.polygonPoints)
      ..writeByte(5)
      ..write(obj.roverPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
