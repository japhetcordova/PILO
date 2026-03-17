import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/ai_service.dart';
import '../presentation/ai_provider.dart';
import '../../inventory/presentation/pantry_providers.dart';
import 'cooking_mode.dart';

class RecipeDecisionScreen extends ConsumerStatefulWidget {
  const RecipeDecisionScreen({super.key});

  @override
  ConsumerState<RecipeDecisionScreen> createState() => _RecipeDecisionScreenState();
}

class _RecipeDecisionScreenState extends ConsumerState<RecipeDecisionScreen> {
  String? _recipe;
  bool _isLoading = true;
  RecipeCategory _selectedCategory = RecipeCategory.meal;
  String _currentWittyMessage = 'PILO IS SNIFFING OUT A MEAL...';
  late final List<String> _wittyMessages = [
    'PILO IS SNIFFING OUT A MEAL...',
    'HINAHANAP KO PA YUNG SANDOK...',
    'TEKA LANG, CHIEF! HUNTING ITEMS MUNA...',
    'CHECKING THE FRIDGE FOR MAGIC...',
    'PILO IS PUTTING ON THE CHEF HAT...',
  ];
  int _wittyIndex = 0;

  @override
  void initState() {
    super.initState();
    // Don't generate immediately; wait for user to confirm category or use default
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _recipe = null;
    });
    
    _startWittyTimer();
    final items = ref.read(pantryItemsProvider);
    final aiService = ref.read(aiServiceProvider);
    final recipeText = await aiService.generateRecipe(items, category: _selectedCategory);
    
    // Add artificial delay to feel more "premium" and intentional
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _recipe = recipeText;
        _isLoading = false;
      });
    }
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
      appBar: AppBar(title: const Text('PILO\'S DISCOVERY')),
      body: _isLoading
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
                  Text(
                    'PILO NEEDS A DIRECTION:',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        Container(
                          padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _recipe ?? 'Pilo couldn\'t find anything today.',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -30,
                          right: 20,
                          child: Image.asset(
                            _recipe == null ? 'assets/images/pilo_sad.png' : 'assets/images/pilo_had_an_idea.png', 
                            width: 80, 
                            height: 80
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_recipe != null)
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CookingModeScreen(recipe: _recipe!),
                        ),
                      ),
                      child: const Text('COOK SMART'),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _generate,
                    child: const Center(child: Text('ASK PILO AGAIN')),
                  ),
                ],
              ),
            ),
    );
  }
}
