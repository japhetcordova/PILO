import 'package:hive/hive.dart';
import 'package:pilo/features/inventory/domain/models/pantry_item.dart';
import 'recipe_model.dart';

part 'recipe_book_item.g.dart';

@HiveType(typeId: 7)
class RecipeBookItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String upgrade;

  @HiveField(3)
  final List<String> ingredients; // Store names for simplicity in recipe book

  @HiveField(4)
  final List<RecipeStep> steps;

  @HiveField(5)
  final int time;

  @HiveField(6)
  final String difficulty;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String source; // "AI" or "Manual"

  RecipeBookItem({
    required this.id,
    required this.name,
    required this.upgrade,
    required this.ingredients,
    required this.steps,
    required this.time,
    required this.difficulty,
    required this.createdAt,
    this.source = 'AI',
  });

  factory RecipeBookItem.fromModel(RecipeModel model) {
    return RecipeBookItem(
      id: model.id,
      name: model.name,
      upgrade: model.upgrade,
      ingredients: model.ingredients.map((e) => e.name).toList(),
      steps: model.steps,
      time: model.time,
      difficulty: model.difficulty,
      createdAt: DateTime.now(),
    );
  }
}
