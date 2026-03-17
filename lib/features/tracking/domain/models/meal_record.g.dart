// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealRecordAdapter extends TypeAdapter<MealRecord> {
  @override
  final int typeId = 2;

  @override
  MealRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mealType: fields[2] as String,
      recipeName: fields[3] as String,
      goCount: fields[4] as int,
      growCount: fields[5] as int,
      glowCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MealRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.recipeName)
      ..writeByte(4)
      ..write(obj.goCount)
      ..writeByte(5)
      ..write(obj.growCount)
      ..writeByte(6)
      ..write(obj.glowCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
