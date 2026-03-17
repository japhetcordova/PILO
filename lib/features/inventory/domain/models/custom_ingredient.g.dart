// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_ingredient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomIngredientAdapter extends TypeAdapter<CustomIngredient> {
  @override
  final int typeId = 1;

  @override
  CustomIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomIngredient(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      commonUses: fields[3] as String,
      color: fields[4] as String,
      isSynced: fields[5] as bool,
      dateAdded: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomIngredient obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.commonUses)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.isSynced)
      ..writeByte(6)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomIngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
