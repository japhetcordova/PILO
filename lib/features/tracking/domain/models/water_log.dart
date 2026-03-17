import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 5)
class WaterLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int glasses;

  WaterLog({
    required this.id,
    required this.date,
    this.glasses = 1,
  });
}
