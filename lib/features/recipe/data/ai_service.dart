import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'package:hive/hive.dart';
import 'brain_downloader.dart';
import '../../inventory/domain/models/pantry_item.dart';
import '../../inventory/domain/models/custom_ingredient.dart';

enum RecipeCategory { meal, snack, beverage, dessert }

class AiService {
  LlmInferenceEngine? _engine;
  bool _isLoaded = false;
  Future<void>? _initFuture;

  Future<void> initialize() {
    _initFuture ??= _doInitialize();
    return _initFuture!;
  }

  Future<void> _doInitialize() async {
    try {
      final modelPath = await BrainDownloader.localPath;
      final localFile = File(modelPath);

      if (await localFile.exists()) {
        debugPrint('AiService: Found brain model at $modelPath. Loading...');
        final options = LlmInferenceOptions.gpu(
          modelPath: modelPath,
          sequenceBatchSize: 0,
          topK: 40,
          maxTokens: 512,
          temperature: 0.8,
          randomSeed: 42,
        );
        _engine = LlmInferenceEngine(options);
        _isLoaded = true; 
        debugPrint('AiService: Engine loaded successfully.');
      } else {
        debugPrint('AiService: Brain model NOT found at $modelPath. Falling back to simple chef logic.');
        _isLoaded = false;
      }
    } catch (e) {
      debugPrint('AiService initialization failed: $e');
      _isLoaded = false;
    }
  }

  Future<List<String>> generateRecipes(
    List<PantryItem> items, {
    RecipeCategory category = RecipeCategory.meal,
    String? mealType,
    int count = 3,
  }) async {
    await initialize();
    if (!_isLoaded || _engine == null) {
      return [_getFallbackRecipe(items)];
    }

    final itemNames = items.map((e) => e.name).join(', ');
    final categoryName = category.name.toUpperCase();
    
    final customBox = Hive.box<CustomIngredient>('custom_ingredients');
    final customValues = customBox.values.toList();
    
    String customContext = '';
    for (var item in items) {
      final matches = customValues.where((c) => c.name.toLowerCase() == item.name.toLowerCase()).toList();
      if (matches.isNotEmpty) {
        customContext += matches.first.toLearningContext() + '\n';
      }
    }

    final contextString = customContext.isNotEmpty 
      ? "Here is some local knowledge about these ingredients:\n$customContext\n" 
      : "";

    final mealContext = mealType != null ? "This is specifically for a $mealType meal." : "";

    final prompt = """
      You are an expert, professional culinary AI assistant.
      $contextString
      $mealContext
      Based on the following available ingredients: $itemNames, provide exactly $count distinct $categoryName recipe options.
      
      For each option, provide:
      1. A unique recipe name
      2. A brief 'Chef's Suggestion': Recommend ONE or TWO additional ingredients the user might not have that would elevate this specific dish to a premium level.
      3. Precise preparation steps.
      
      Maintain a formal, professional, and highly detailed tone.
      
      Format each recipe separately as:
      ---RECIPE START---
      RECIPE: [Name]
      CHEF'S UPGRADE: [Proposed 1-2 extra ingredients and why]
      INGREDIENTS: [List of available ingredients used + the upgrades]
      STEPS: [Numbered List]
      TIME: [Minutes]
      ---RECIPE END---
    """;

    try {
      final responseStream = _engine!.generateResponse(prompt);
      final fullResponse = await responseStream.join('');
      
      // Split by marker
      final parts = fullResponse.split('---RECIPE START---')
          .where((p) => p.contains('---RECIPE END---'))
          .map((p) => p.split('---RECIPE END---').first.trim())
          .toList();
          
      return parts.isNotEmpty ? parts : [fullResponse];
    } catch (e) {
      debugPrint('Multi-recipe generation failed: $e');
      return [_getFallbackRecipe(items)];
    }
  }

  String _getFallbackRecipe(List<PantryItem> items) {
    if (items.isEmpty) return "Sufficient ingredients are required to generate a recipe. Please add items to your inventory.";
    final mainItem = items.isNotEmpty ? items.first.name : "Ingredients";
    return """
RECIPE: Professional Quick $mainItem Preparation
CHEF'S UPGRADE: Fresh Herbs (Parsley or Cilantro) and a squeeze of Lemon to brighten the flavors.
INGREDIENTS: ${items.map((e) => e.name).join(', ')}, Cooking Oil, Salt.
STEPS: 
1. Carefully prepare and chop all ingredients to a uniform size. 
2. Heat oil in a suitable pan over medium heat. 
3. Sauté the ingredients until fully cooked and aromatic. 
4. Season with salt to taste and serve immediately.
TIME: 15
    """;
  }
}
