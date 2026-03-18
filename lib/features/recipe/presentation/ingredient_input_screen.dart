import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/ai_service.dart';
import '../../inventory/presentation/pantry_providers.dart';
import '../../inventory/domain/models/pantry_item.dart';
import 'recipe_decision_screen.dart';

class IngredientInputScreen extends ConsumerStatefulWidget {
  final RecipeCategory category;
  final String mealType;

  const IngredientInputScreen({
    super.key,
    required this.category,
    required this.mealType,
  });

  @override
  ConsumerState<IngredientInputScreen> createState() => _IngredientInputScreenState();
}

class _IngredientInputScreenState extends ConsumerState<IngredientInputScreen> {
  final TextEditingController _customController = TextEditingController();
  final List<String> _selectedIngredients = [];
  final List<String> _customIngredients = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill with all current pantry items as a starting point
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(filteredPantryItemsProvider);
      setState(() {
        _selectedIngredients.addAll(items.map((e) => e.name));
      });
    });
  }

  void _addCustom() {
    if (_customController.text.trim().isNotEmpty) {
      setState(() {
        _customIngredients.add(_customController.text.trim());
        _customController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pantryItems = ref.watch(filteredPantryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('WHAT\'S IN THE PANTRY?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select ingredients for your ${widget.mealType}',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              'PANTRY ITEMS',
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pantryItems.map((item) {
                      final isSelected = _selectedIngredients.contains(item.name);
                      return FilterChip(
                        label: Text(item.name),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedIngredients.add(item.name);
                            } else {
                              _selectedIngredients.remove(item.name);
                            }
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'EXTRA INGREDIENTS',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController,
                          decoration: InputDecoration(
                            hintText: 'Add an extra item...',
                            hintStyle: GoogleFonts.outfit(fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _addCustom(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addCustom,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _customIngredients.map((item) {
                      return Chip(
                        label: Text(item),
                        onDeleted: () {
                          setState(() {
                            _customIngredients.remove(item);
                          });
                        },
                        deleteIconColor: Colors.red[300],
                        labelStyle: GoogleFonts.outfit(fontSize: 12),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedIngredients.isEmpty && _customIngredients.isEmpty)
                    ? null
                    : () {
                        // Map selected pantry names back to items for the generator
                        final finalItems = pantryItems.where((p) => _selectedIngredients.contains(p.name)).toList();
                        // Create temporary pantry items for custom ones
                        for (var c in _customIngredients) {
                          finalItems.add(PantryItem(
                            id: 'temp-$c',
                            name: c,
                            dateAdded: DateTime.now(),
                            nutritionalCategory: NutritionalCategory.unknown,
                          ));
                        }
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDecisionScreen(
                              initialItems: finalItems,
                              category: widget.category,
                              mealType: widget.mealType,
                            ),
                          ),
                        );
                      },
                child: const Text('GENERATE MY MENU'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
