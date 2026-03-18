// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_book_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeBookItemAdapter extends TypeAdapter<RecipeBookItem> {
  @override
  final int typeId = 7;

  @override
  RecipeBookItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeBookItem(
      id: fields[0] as String,
      name: fields[1] as String,
      upgrade: fields[2] as String,
      ingredients: (fields[3] as List).cast<String>(),
      steps: (fields[4] as List).cast<RecipeStep>(),
      time: fields[5] as int,
      difficulty: fields[6] as String,
      createdAt: fields[7] as DateTime,
      source: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeBookItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.upgrade)
      ..writeByte(3)
      ..write(obj.ingredients)
      ..writeByte(4)
      ..write(obj.steps)
      ..writeByte(5)
      ..write(obj.time)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeBookItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
