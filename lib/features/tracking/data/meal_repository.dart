import 'package:hive/hive.dart';
import '../domain/models/meal_record.dart';

class MealRepository {
  static const String _boxName = 'meal_records';

  Future<void> addRecord(MealRecord record) async {
    final box = Hive.box<MealRecord>(_boxName);
    await box.put(record.id, record);
  }

  Future<List<MealRecord>> getAllRecords() async {
    final box = Hive.box<MealRecord>(_boxName);
    return box.values.toList();
  }

  Future<void> deleteRecord(String id) async {
    final box = Hive.box<MealRecord>(_boxName);
    await box.delete(id);
  }
}
