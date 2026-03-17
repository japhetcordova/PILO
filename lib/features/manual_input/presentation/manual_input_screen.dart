import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../inventory/presentation/pantry_providers.dart';
import '../../inventory/domain/models/pantry_item.dart';
import 'ingredient_training_screen.dart';

class ManualInputScreen extends ConsumerStatefulWidget {
  const ManualInputScreen({super.key});

  @override
  ConsumerState<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends ConsumerState<ManualInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  NutritionalCategory _selectedCategory = NutritionalCategory.unknown;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final activeGroup = ref.read(selectedPantryGroupProvider);

    final newItem = PantryItem(
      id: const Uuid().v4(),
      name: text,
      dateAdded: DateTime.now(),
      pantryGroup: activeGroup,
      nutritionalCategory: _selectedCategory,
    );

    await ref.read(pantryItemsProvider.notifier).addItem(newItem);
    
    final categoryName = _selectedCategory.name.toUpperCase();
    
    // Clear the field for next input
    _controller.clear();
    setState(() {
      _selectedCategory = NutritionalCategory.unknown;
    });
    
    // Check if widget is still mounted before showing snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $text ($categoryName) to your $activeGroup pantry'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch recently added items for the session, or simply the whole pantry sorted by date added desc
    final allItems = ref.watch(pantryItemsProvider);
    final sortedItems = List<PantryItem>.from(allItems)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ingredients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT NUTRITION CATEGORY:',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: NutritionalCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    Color color = Colors.grey;
                    if (cat == NutritionalCategory.go) color = Colors.orange;
                    if (cat == NutritionalCategory.grow) color = Colors.redAccent;
                    if (cat == NutritionalCategory.glow) color = Colors.green;

                    return ChoiceChip(
                      label: Text(cat.name.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = selected ? cat : NutritionalCategory.unknown);
                      },
                      selectedColor: color.withOpacity(0.2),
                      checkmarkColor: color,
                      labelStyle: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Colors.grey[600],
                      ),
                      side: BorderSide(
                        color: isSelected ? color : Colors.transparent,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'e.g., Kangkong, Pork Belly...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        minimumSize: const Size(60, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECENTLY ADDED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: sortedItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items added yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.restaurant, color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(item.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            ref.read(pantryItemsProvider.notifier).deleteItem(item.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IngredientTrainingScreen(initialName: _controller.text),
                  ),
                );
              },
              icon: const Icon(Icons.school),
              label: const Text('TEACH PILO A NEW INGREDIENT'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
