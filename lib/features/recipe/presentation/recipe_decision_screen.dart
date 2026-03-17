import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
    _generate();
  }

  Future<void> _generate() async {
    _startWittyTimer();
    final items = ref.read(pantryItemsProvider);
    final aiService = ref.read(aiServiceProvider);
    final recipeText = await aiService.generateRecipe(items);
    
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
                    child: Image.asset('assets/images/pilo_pixel.png', width: 80, height: 80),
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
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
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
                  ),
                  const SizedBox(height: 20),
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
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _generate();
                    },
                    child: const Center(child: Text('ASK PILO AGAIN')),
                  ),
                ],
              ),
            ),
    );
  }
}
