import 'package:hive/hive.dart';

part 'custom_ingredient.g.dart';

@HiveType(typeId: 1)
class CustomIngredient extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String commonUses;

  @HiveField(4)
  final String color;

  @HiveField(5)
  bool isSynced;
  
  @HiveField(6)
  final DateTime dateAdded;

  CustomIngredient({
    required this.id,
    required this.name,
    this.description = '',
    this.commonUses = '',
    this.color = '',
    this.isSynced = false,
    required this.dateAdded,
  });

  // Helper method for the LLM prompt context
  String toLearningContext() {
    return 'Ingredient: $name (Details: $description, Common Uses: $commonUses, Color: $color)';
  }
}
