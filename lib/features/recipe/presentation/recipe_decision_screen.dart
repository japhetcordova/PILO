import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_service.dart';
import '../../inventory/presentation/pantry_providers.dart';
import 'cooking_mode.dart';

class RecipeDecisionScreen extends ConsumerStatefulWidget {
  const RecipeDecisionScreen({super.key});

  @override
  ConsumerState<RecipeDecisionScreen> createState() => _RecipeDecisionScreenState();
}

class _RecipeDecisionScreenState extends ConsumerState<RecipeDecisionScreen> {
  final AiService _aiService = AiService();
  String? _recipe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    final items = ref.read(pantryItemsProvider);
    final recipeText = await _aiService.generateRecipe(items);
    setState(() {
      _recipe = recipeText;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PILO\'S DISCOVERY')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF5722)),
                  SizedBox(height: 20),
                  Text('PILO IS SNIFFING OUT A MEAL...', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _recipe ?? 'Pilo couldn\'t find anything today.',
                        style: const TextStyle(fontSize: 18, height: 1.5),
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
