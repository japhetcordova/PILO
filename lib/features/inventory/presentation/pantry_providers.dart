import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pantry_repository.dart';
import '../domain/models/pantry_item.dart';

final pantryRepositoryProvider = Provider((ref) => PantryRepository());

final pantryItemsProvider = StateNotifierProvider<PantryItemsNotifier, List<PantryItem>>((ref) {
  return PantryItemsNotifier(ref.watch(pantryRepositoryProvider));
});

// Create a state provider to keep track of the selected tab
final selectedPantryGroupProvider = StateProvider<String>((ref) => 'All');

// Provide a filtered list based on the selected group
final filteredPantryItemsProvider = Provider<List<PantryItem>>((ref) {
  final group = ref.watch(selectedPantryGroupProvider);
  final allItems = ref.watch(pantryItemsProvider);
  
  if (group == 'All') return allItems;
  return allItems.where((item) => item.pantryGroup == group).toList();
});

class PantryItemsNotifier extends StateNotifier<List<PantryItem>> {
  final PantryRepository _repository;

  PantryItemsNotifier(this._repository) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = await _repository.getAllItems();
  }

  Future<void> addItem(PantryItem item) async {
    await _repository.addItem(item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    await loadItems();
  }
}
