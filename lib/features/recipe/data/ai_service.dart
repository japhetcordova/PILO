import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'brain_downloader.dart';
import '../../inventory/domain/models/pantry_item.dart';

enum RecipeCategory { meal, snack, beverage, dessert }

class AiService {
  LlmInferenceEngine? _engine;
  bool _isLoaded = false;

  Future<void> initialize() async {
    try {
      final modelPath = await BrainDownloader.localPath;
      final localFile = File(modelPath);

      if (await localFile.exists()) {
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
      }
    } catch (e) {
      debugPrint('AiService initialization failed: $e');
      _isLoaded = false;
    }
  }

  Future<String> generateRecipe(List<PantryItem> items, {RecipeCategory category = RecipeCategory.meal}) async {
    if (!_isLoaded || _engine == null) return _getFallbackRecipe(items);

    final itemNames = items.map((e) => e.name).join(', ');
    final categoryName = category.name.toUpperCase();
    
    final prompt = """
      You are Pilo, a clever Filipino mouse deer chef who hates waste. 
      Give me EXACTLY ONE $categoryName recipe that uses ALL these ingredients: $itemNames.
      If some ingredients don't fit a $categoryName, be creative or mention how you utilized them cleverly!
      Use a witty, helpful persona. Inject some Filipino flavor in your text (e.g., 'Sarap!', 'Ayayay!', 'Chief').
      Format:
      RECIPE: [Name]
      INGREDIENTS: [List]
      STEPS: [Numbered List]
      TIME: [Minutes]
      Be helpful, zero-waste focused, and witty like a Pilo.
    """;

    try {
      final responseStream = _engine!.generateResponse(prompt);
      return await responseStream.join('');
    } catch (e) {
      debugPrint('Recipe generation failed: $e');
      return _getFallbackRecipe(items);
    }
  }

  String _getFallbackRecipe(List<PantryItem> items) {
    if (items.isEmpty) return "Pilo has no ingredients to sniff! Scan some items first.";
    final mainItem = items.first.name;
    return """
      RECIPE: Pilo's Quick $mainItem Sauté
      INGREDIENTS: ${items.map((e) => e.name).join(', ')}, Magic oil, Salt.
      STEPS: 1. Chop everything with mouse deer precision. 2. Heat oil in a pan. 3. Sauté and sniff the aroma. 4. Season and serve!
      TIME: 15
    """;
  }
}
