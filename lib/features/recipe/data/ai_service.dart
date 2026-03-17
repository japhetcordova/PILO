import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'brain_downloader.dart';
import '../../inventory/domain/models/pantry_item.dart';

class AiService {
  dynamic _engine;
  bool _isLoaded = false;

  Future<void> initialize() async {
    try {
      final modelPath = await BrainDownloader.localPath;
      final localFile = File(modelPath);

      if (await localFile.exists()) {
        _isLoaded = true; 
      }
    } catch (e) {
      _isLoaded = false;
    }
  }

  Future<String> generateRecipe(List<PantryItem> items) async {
    if (!_isLoaded) return _getFallbackRecipe(items);

    final itemNames = items.map((e) => e.name).join(', ');
    final prompt = """
      You are Pilo, a clever Filipino mouse deer chef. 
      Give me EXACTLY ONE recipe based on these ingredients: $itemNames.
      Format:
      RECIPE: [Name]
      INGREDIENTS: [List]
      STEPS: [Numbered List]
      TIME: [Minutes]
      Be helpful and witty like a Pilo.
    """;

    try {
      final response = await _engine.generateResponse(prompt);
      return response;
    } catch (e) {
      return _getFallbackRecipe(items);
    }
  }

  String _getFallbackRecipe(List<PantryItem> items) {
    final mainItem = items.first.name;
    return """
      RECIPE: Pilo's Quick $mainItem Sauté
      INGREDIENTS: ${items.map((e) => e.name).join(', ')}, Magic oil, Salt.
      STEPS: 1. Chop everything with mouse deer precision. 2. Heat oil in a pan. 3. Sauté and sniff the aroma. 4. Season and serve!
      TIME: 15
    """;
  }
}
