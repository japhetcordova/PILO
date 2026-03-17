import 'package:hive/hive.dart';

part 'pantry_item.g.dart';

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

  PantryItem({
    required this.id,
    required this.name,
    required this.dateAdded,
    this.expirationDate,
    this.quantity = 1.0,
  });
}
