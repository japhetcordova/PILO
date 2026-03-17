import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/meal_repository.dart';
import '../domain/models/meal_record.dart';

final mealRepositoryProvider = Provider((ref) => MealRepository());

final mealRecordsProvider = StateNotifierProvider<MealRecordsNotifier, List<MealRecord>>((ref) {
  return MealRecordsNotifier(ref.watch(mealRepositoryProvider));
});

class MealRecordsNotifier extends StateNotifier<List<MealRecord>> {
  final MealRepository _repository;

  MealRecordsNotifier(this._repository) : super([]) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = await _repository.getAllRecords();
  }

  Future<void> addRecord(MealRecord record) async {
    await _repository.addRecord(record);
    await loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _repository.deleteRecord(id);
    await loadRecords();
  }
}
