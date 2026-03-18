// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeStepAdapter extends TypeAdapter<RecipeStep> {
  @override
  final int typeId = 6;

  @override
  RecipeStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeStep(
      title: fields[0] as String,
      details: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecipeStep obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
