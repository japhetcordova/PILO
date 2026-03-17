// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PantryItemAdapter extends TypeAdapter<PantryItem> {
  @override
  final int typeId = 0;

  @override
  PantryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PantryItem(
      id: fields[0] as String,
      name: fields[1] as String,
      dateAdded: fields[2] as DateTime,
      expirationDate: fields[3] as DateTime?,
      quantity: fields[4] as double,
      pantryGroup: fields[5] as String,
      nutritionalCategory: fields[6] as NutritionalCategory,
    );
  }

  @override
  void write(BinaryWriter writer, PantryItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dateAdded)
      ..writeByte(3)
      ..write(obj.expirationDate)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.pantryGroup)
      ..writeByte(6)
      ..write(obj.nutritionalCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionalCategoryAdapter extends TypeAdapter<NutritionalCategory> {
  @override
  final int typeId = 4;

  @override
  NutritionalCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NutritionalCategory.go;
      case 1:
        return NutritionalCategory.grow;
      case 2:
        return NutritionalCategory.glow;
      case 3:
        return NutritionalCategory.unknown;
      default:
        return NutritionalCategory.go;
    }
  }

  @override
  void write(BinaryWriter writer, NutritionalCategory obj) {
    switch (obj) {
      case NutritionalCategory.go:
        writer.writeByte(0);
        break;
      case NutritionalCategory.grow:
        writer.writeByte(1);
        break;
      case NutritionalCategory.glow:
        writer.writeByte(2);
        break;
      case NutritionalCategory.unknown:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionalCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
