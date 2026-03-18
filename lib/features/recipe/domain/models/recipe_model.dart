import 'package:hive/hive.dart';
import 'package:pilo/features/inventory/domain/models/pantry_item.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 6)
class RecipeStep {
  @HiveField(0)
  final String title;
  
  @HiveField(1)
  final List<String> details;

  const RecipeStep({required this.title, required this.details});
}

class RecipeModel {
  final String id;
  final String name;
  final String upgrade;
  final List<PantryItem> ingredients;
  final List<RecipeStep> steps;
  final int time;
  final String difficulty;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.upgrade,
    required this.ingredients,
    required this.steps,
    required this.time,
    this.difficulty = 'Easy',
  });
}
