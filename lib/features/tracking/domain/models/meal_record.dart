import 'package:hive/hive.dart';

part 'meal_record.g.dart';

@HiveType(typeId: 2)
class MealRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String mealType; // 'Breakfast', 'Lunch', 'Dinner'

  @HiveField(3)
  final String recipeName;

  @HiveField(4)
  final int goCount;

  @HiveField(5)
  final int growCount;

  @HiveField(6)
  final int glowCount;

  MealRecord({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeName,
    this.goCount = 0,
    this.growCount = 0,
    this.glowCount = 0,
  });
}
