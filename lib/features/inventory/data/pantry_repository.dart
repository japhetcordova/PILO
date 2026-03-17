import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/pantry_item.dart';

class PantryRepository {
  static const String boxName = 'pantry_items';

  Future<Box<PantryItem>> _getBox() async {
    return await Hive.openBox<PantryItem>(boxName);
  }

  Future<void> addItem(PantryItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  Future<List<PantryItem>> getAllItems() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> deleteItem(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
