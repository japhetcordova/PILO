import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'package:hive/hive.dart';
import 'brain_downloader.dart';
import 'local_recipe_database.dart';
import '../../inventory/domain/models/pantry_item.dart';
import '../../inventory/domain/models/custom_ingredient.dart';

enum RecipeCategory { meal, snack, beverage, dessert }

class AiService {
  LlmInferenceEngine? _engine;
  bool _isLoaded = false;
  Future<void>? _initFuture;

  Future<void> initialize() async {
    _initFuture ??= _doInitialize();
    await _initFuture;
  }

  Future<void> _doInitialize() async {
    try {
      // MediaPipe GenAI does not support x86/x86_64 emulators.
      // We check the Platform version or arch to avoid hard-crashing the app.
      if (Platform.isAndroid) {
        // Simple check to skip on x86/x86_64 emulators which usually have 'sdk_gphone' or similar in version information
        // or we can check the CPU architecture if available.
        final version = Platform.version.toLowerCase();
        if (version.contains('x86') || version.contains('x64')) {
          debugPrint('AiService: Running on x86/x64 architecture. Skipping MediaPipe to avoid native crash.');
          _isLoaded = false;
          return;
        }
      }

      final modelPath = await BrainDownloader.localPath;
      final localFile = File(modelPath);

      if (await localFile.exists()) {
        debugPrint('AiService: Found brain model at $modelPath. Loading...');
        try {
          final options = LlmInferenceOptions.gpu(
            modelPath: modelPath,
            sequenceBatchSize: 0,
            topK: 64,
            maxTokens: 1024,
            temperature: 0.8,
            randomSeed: 42,
          );
          _engine = LlmInferenceEngine(options);
          _isLoaded = true; 
          debugPrint('AiService: Engine loaded successfully.');
        } on ArgumentError catch (e) {
          debugPrint('AiService: Native FFI Error (Likely incompatible device/emulator): $e');
          _isLoaded = false;
        } catch (e) {
          debugPrint('AiService: Engine initialization error: $e');
          _isLoaded = false;
        }
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
      return _getFallbackRecipes(items);
    }

    final itemNames = items.map((e) {
      // Basic sanitization: remove special characters and limit length
      final sanitized = e.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      return sanitized.length > 50 ? sanitized.substring(0, 50) : sanitized;
    }).join(', ');
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
    } on ArgumentError catch (e) {
      debugPrint('AiService: Native FFI Error during generation: $e');
      return _getFallbackRecipes(items);
    } catch (e) {
      debugPrint('Multi-recipe generation failed: $e');
      return _getFallbackRecipes(items);
    }
  }

  List<String> _getFallbackRecipes(List<PantryItem> items) {
    if (items.isEmpty) {
      return ["Sufficient ingredients are required to generate a recipe. Please add items to your inventory."];
    }

    // Determine available categories
    final availableCategories = items
        .map((e) => e.nutritionalCategory.name.toLowerCase())
        .toSet();
    
    final itemNames = items.map((e) => e.name).toList();

    // Score and filter curated recipes
    final matches = curatedRecipes.where((recipe) {
      // Recipe matches if the user has AT LEAST ONE of the required categories
      return recipe.requiredCategories.any((cat) => availableCategories.contains(cat));
    }).toList();

    // Sort by best match (most categories covered)
    matches.sort((a, b) {
      final aCovered = a.requiredCategories.where((cat) => availableCategories.contains(cat)).length;
      final bCovered = b.requiredCategories.where((cat) => availableCategories.contains(cat)).length;
      return bCovered.compareTo(aCovered);
    });

    final results = matches.take(3).map((r) => r.toFormattedString(itemNames)).toList();

    if (results.isEmpty) {
      // Absolute fallback if no categories match (unlikely)
      return [
        "RECIPE: Chef's Pantry Surprise\n"
        "CHEF'S UPGRADE: A touch of salt and high heat.\n"
        "INGREDIENTS: ${itemNames.join(', ')}\n"
        "STEPS: 1. Sauté everything together until aromatic. 2. Serve immediately.\n"
        "TIME: 10"
      ];
    }

    return results;
  }
}
