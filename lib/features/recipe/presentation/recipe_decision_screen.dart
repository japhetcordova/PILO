import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:pilo/features/recipe/data/ai_service.dart';
import 'package:pilo/features/recipe/domain/models/recipe_model.dart';
import 'package:pilo/features/inventory/domain/models/pantry_item.dart';
import 'package:pilo/features/inventory/presentation/pantry_providers.dart';
import 'package:pilo/features/tracking/domain/models/meal_record.dart';
import 'package:pilo/features/tracking/presentation/meal_providers.dart';
import 'package:pilo/features/inventory/presentation/onboarding_screen.dart';
import 'package:pilo/features/recipe/presentation/brain_status_provider.dart';
import 'package:pilo/features/recipe/presentation/ai_provider.dart';
import 'cooking_mode.dart';

class RecipeDecisionScreen extends ConsumerStatefulWidget {
  final List<PantryItem>? initialItems;
  final RecipeCategory category;
  final String? mealType;

  const RecipeDecisionScreen({
    super.key,
    this.initialItems,
    this.category = RecipeCategory.meal,
    this.mealType,
  });

  @override
  ConsumerState<RecipeDecisionScreen> createState() => _RecipeDecisionScreenState();
}

class _RecipeDecisionScreenState extends ConsumerState<RecipeDecisionScreen> {
  List<RecipeModel> _recipes = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  late RecipeCategory _selectedCategory;
  String _currentWittyMessage = 'ANALYZING INGREDIENTS...';
  late final List<String> _wittyMessages = [
    'ANALYZING INGREDIENTS...',
    'EVALUATING CULINARY PROFILES...',
    'STRUCTURING RECIPE OPTIONS...',
    'INJECTING CHEF SUGGESTIONS...',
    'FINALIZING CULINARY VARIATIONS...',
  ];
  int _wittyIndex = 0;
  final Set<int> _expandedSteps = {};

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _generate();
  }

  Future<void> _generate({bool append = false}) async {
    setState(() {
      _isLoading = true;
      if (!append) {
        _recipes = [];
        _currentIndex = 0;
      }
    });
    
    _startWittyTimer();
    final List<PantryItem> items = widget.initialItems ?? ref.read(filteredPantryItemsProvider);
    final String activeGroup = widget.mealType ?? ref.read(selectedPantryGroupProvider);
    final aiService = ref.read(aiServiceProvider);
    
    final results = await aiService.generateRecipes(
      items, 
      category: _selectedCategory,
      mealType: activeGroup,
      count: append ? 2 : 3,
    );
    
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        if (append) {
          _recipes.addAll(results);
          _currentIndex = _recipes.length - results.length;
        } else {
          _recipes = results;
        }
        _isLoading = false;
      });
    }
  }

  void _logMeal({DateTime? customDate}) async {
    if (_recipes.isEmpty) return;
    final currentRecipe = _recipes[_currentIndex];
    final recipeName = currentRecipe.name;

    final activeGroup = widget.mealType ?? ref.read(selectedPantryGroupProvider);
    
    int go = 0;
    int grow = 0;
    int glow = 0;
    
    for (var item in currentRecipe.ingredients) {
      if (item.nutritionalCategory == NutritionalCategory.go) go++;
      if (item.nutritionalCategory == NutritionalCategory.grow) grow++;
      if (item.nutritionalCategory == NutritionalCategory.glow) glow++;
    }
    
    final record = MealRecord(
      id: Uuid().v4(),
      date: customDate ?? DateTime.now(),
      mealType: widget.mealType ?? 'meal',
      recipeName: recipeName,
      goCount: go,
      growCount: grow,
      glowCount: glow,
    );

    await ref.read(mealRecordsProvider.notifier).addRecord(record);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged $recipeName for ${DateFormat('MMM d').format(record.date)}!'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mealType?.toUpperCase() ?? "RECIPES"}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _generate(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    _currentWittyMessage,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildRecipeContent(),
                        _buildNavigationArrows(),
                      ],
                    ),
                  ),
                  _buildBottomActions(),
                ],
              ),
            ),
    );
  }



  Widget _buildRecipeContent() {
    if (_recipes.isEmpty) {
      return const Center(child: Text('No recipes found. Try adding more ingredients!'));
    }

    final recipe = _recipes[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildRecipeHeader(recipe),
          const SizedBox(height: 24),
          _buildAdditionalIngredients(recipe),
          const SizedBox(height: 24),
          _buildIngredients(recipe),
          const SizedBox(height: 32),
          _buildExpandableSteps(recipe),
          const SizedBox(height: 32),
          _buildGenerateMoreButton(),
        ],
      ),
    );
  }

  Widget _buildRecipeHeader(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getDifficultyColor(recipe.difficulty).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recipe.difficulty.toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: _getDifficultyColor(recipe.difficulty)),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${recipe.time} MINS',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          recipe.name.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
        ),
      ],
    );
  }

  Widget _buildAdditionalIngredients(RecipeModel recipe) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text(
                'ADDITIONAL NEEDED INGREDIENTS',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.orange[800], letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipe.upgrade,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INGREDIENTS',
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recipe.ingredients.map<Widget>((item) {
            final color = _getCategoryColor(item.nutritionalCategory);
            return ActionChip(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name}: ${item.nutritionalCategory.name.toUpperCase()} item.'),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              label: Text(item.name),
              avatar: CircleAvatar(backgroundColor: color, radius: 6),
              backgroundColor: Colors.white,
              side: BorderSide(color: color.withOpacity(0.2)),
              labelStyle: GoogleFonts.outfit(fontSize: 12),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpandableSteps(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREPARATION STEPS',
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        ...recipe.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isExpanded = _expandedSteps.contains(index);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: isExpanded,
                onExpansionChanged: (val) {
                  setState(() {
                    if (val) _expandedSteps.add(index);
                    else _expandedSteps.remove(index);
                  });
                },
                title: Text(
                  'PHASE ${index + 1}: ${step.title.toUpperCase()}',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text('${index + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(52, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: step.details.map((detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: Icon(Icons.circle, size: 4, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(detail, style: GoogleFonts.outfit(fontSize: 14, height: 1.5))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGenerateMoreButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => _generate(append: true),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('SHOW 2 MORE OPTIONS'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[600],
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    if (_recipes.length <= 1) return const SizedBox.shrink();
    return Stack(
      children: [
        if (_currentIndex > 0)
          Positioned(
            left: 0,
            top: 150,
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.chevron_left, color: Colors.black),
              ),
              onPressed: () => setState(() {
                _currentIndex--;
                _expandedSteps.clear();
              }),
            ),
          ),
        if (_currentIndex < _recipes.length - 1)
          Positioned(
            right: 0,
            top: 150,
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.chevron_right, color: Colors.black),
              ),
              onPressed: () => setState(() {
                _currentIndex++;
                _expandedSteps.clear();
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomActions() {
    if (_recipes.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _logMeal(); // Auto-save to stats and calendar
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CookingModeScreen(recipe: _recipes[_currentIndex]),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
              child: const Text('START COOKING'),
            ),
          ),
          const SizedBox(width: 16),
          IconButton.filledTonal(
            onPressed: () => _showSchedulingDialog(),
            icon: const Icon(Icons.calendar_month_outlined),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSchedulingDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COOK THIS TODAY?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('Would you like to schedule this meal?', style: GoogleFonts.outfit(color: Colors.grey)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.today, color: Colors.blue),
                title: Text('Today', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onTap: () {
                  _logMeal(customDate: DateTime.now());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.next_plan_outlined, color: Colors.green),
                title: Text('Tomorrow', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onTap: () {
                  _logMeal(customDate: DateTime.now().add(const Duration(days: 1)));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String diff) {
    if (diff.contains('Hard')) return Colors.red;
    if (diff.contains('Medium')) return Colors.orange;
    return Colors.green;
  }

  Color _getCategoryColor(NutritionalCategory category) {
    switch (category) {
      case NutritionalCategory.go: return Colors.blue[600]!;
      case NutritionalCategory.grow: return Colors.green[600]!;
      case NutritionalCategory.glow: return Colors.orange[600]!;
      default: return Colors.grey;
    }
  }
}
