import 'package:hive/hive.dart';

part 'pantry_item.g.dart';

@HiveType(typeId: 4)
enum NutritionalCategory {
  @HiveField(0)
  go,
  @HiveField(1)
  grow,
  @HiveField(2)
  glow,
  @HiveField(3)
  unknown
}

@HiveType(typeId: 0)
class PantryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime dateAdded;

  @HiveField(3)
  final DateTime? expirationDate;

  @HiveField(4)
  final double quantity;

  @HiveField(5)
  final String pantryGroup;

  @HiveField(6)
  final NutritionalCategory nutritionalCategory;

  PantryItem({
    required this.id,
    required this.name,
    required this.dateAdded,
    this.expirationDate,
    this.quantity = 1.0,
    this.pantryGroup = 'All',
    this.nutritionalCategory = NutritionalCategory.unknown,
  });
}
