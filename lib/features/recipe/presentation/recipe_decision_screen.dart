import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/ai_service.dart';
import '../presentation/ai_provider.dart';
import '../../inventory/domain/models/pantry_item.dart';
import '../../inventory/presentation/pantry_providers.dart';
import '../../tracking/domain/models/meal_record.dart';
import '../../tracking/presentation/meal_providers.dart';
import 'package:uuid/uuid.dart';
import 'cooking_mode.dart';
import 'brain_status_provider.dart';

class RecipeDecisionScreen extends ConsumerStatefulWidget {
  const RecipeDecisionScreen({super.key});

  @override
  ConsumerState<RecipeDecisionScreen> createState() => _RecipeDecisionScreenState();
}

class _RecipeDecisionScreenState extends ConsumerState<RecipeDecisionScreen> {
  List<String> _recipes = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  RecipeCategory _selectedCategory = RecipeCategory.meal;
  String _currentWittyMessage = 'ANALYZING INGREDIENTS...';
  late final List<String> _wittyMessages = [
    'ANALYZING INGREDIENTS...',
    'EVALUATING CULINARY PROFILES...',
    'STRUCTURING RECIPE OPTIONS...',
    'INJECTING CHEF SUGGESTIONS...',
    'FINALIZING CULINARY VARIATIONS...',
  ];
  int _wittyIndex = 0;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _recipes = [];
      _currentIndex = 0;
    });
    
    _startWittyTimer();
    final items = ref.read(filteredPantryItemsProvider);
    final activeGroup = ref.read(selectedPantryGroupProvider);
    final aiService = ref.read(aiServiceProvider);
    
    final results = await aiService.generateRecipes(
      items, 
      category: _selectedCategory,
      mealType: activeGroup,
      count: 3,
    );
    
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _recipes = results;
        _isLoading = false;
      });
    }
  }

  void _logMeal() async {
    if (_recipes.isEmpty) return;
    final currentRecipe = _recipes[_currentIndex];

    // Basic parsing of the recipe name
    String recipeName = 'Custom Meal';
    final lines = currentRecipe.split('\n');
    for (var line in lines) {
      if (line.toUpperCase().contains('RECIPE:')) {
        recipeName = line.split(':').last.trim();
        break;
      }
    }

    final activeGroup = ref.read(selectedPantryGroupProvider);
    final items = ref.read(filteredPantryItemsProvider);
    
    int go = 0;
    int grow = 0;
    int glow = 0;
    
    for (var item in items) {
      if (item.nutritionalCategory == NutritionalCategory.go) go++;
      if (item.nutritionalCategory == NutritionalCategory.grow) grow++;
      if (item.nutritionalCategory == NutritionalCategory.glow) glow++;
    }
    
    final record = MealRecord(
      id: const Uuid().v4(),
      date: DateTime.now(),
      mealType: activeGroup,
      recipeName: recipeName,
      goCount: go,
      growCount: grow,
      glowCount: glow,
    );

    await ref.read(mealRecordsProvider.notifier).addRecord(record);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged $recipeName as $activeGroup in your tracker!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startWittyTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!_isLoading || !mounted) return false;
      setState(() {
        _wittyIndex = (_wittyIndex + 1) % _wittyMessages.length;
        _currentWittyMessage = _wittyMessages[_wittyIndex];
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/images/pilo_thinking.png', width: 100, height: 100),
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _currentWittyMessage,
                    style: GoogleFonts.outfit(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CHOOSE YOUR MEAL:',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      if (_recipes.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${_recipes.length}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!ref.watch(brainStatusProvider))
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pilo Brain is missing! Using high-speed fallback logic.',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    children: RecipeCategory.values.map((cat) {
                      return ChoiceChip(
                        label: Text(cat.name.toUpperCase()),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                            _generate();
                          }
                        },
                        labelStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedCategory == cat ? Colors.white : Colors.black87,
                        ),
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey[100],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! < 0 && _currentIndex < _recipes.length - 1) {
                              setState(() => _currentIndex++);
                            } else if (details.primaryVelocity! > 0 && _currentIndex > 0) {
                              setState(() => _currentIndex--);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black.withOpacity(0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _recipes.isNotEmpty 
                                    ? _recipes[_currentIndex] 
                                    : 'No recipe could be generated at this time. Please ensure ingredients are listed.',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -30,
                          right: 20,
                          child: Image.asset(
                            _recipes.isEmpty ? 'assets/images/pilo_sad.png' : 'assets/images/pilo_had_an_idea.png', 
                            width: 80, 
                            height: 80
                          ),
                        ),
                        if (_currentIndex > 0)
                          Positioned(
                            left: -15,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
                                onPressed: () => setState(() => _currentIndex--),
                              ),
                            ),
                          ),
                        if (_currentIndex < _recipes.length - 1)
                          Positioned(
                            right: -15,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                                onPressed: () => setState(() => _currentIndex++),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_recipes.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CookingModeScreen(recipe: _recipes[_currentIndex]),
                              ),
                            ),
                            child: const Text('COOK SMART'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _logMeal,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Icon(Icons.bookmark_add_outlined),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _generate,
                    child: const Center(child: Text('REFRESH ALL OPTIONS')),
                  ),
                ],
              ),
            );
  }
}
