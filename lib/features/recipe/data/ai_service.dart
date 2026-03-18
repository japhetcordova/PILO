import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:pilo/features/inventory/domain/models/pantry_item.dart';
import 'package:pilo/features/inventory/domain/models/custom_ingredient.dart';
import '../domain/models/recipe_model.dart';
import '../domain/models/recipe_book_item.dart';
import 'local_recipe_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'brain_downloader.dart';
import 'package:pilo/core/config/api_config.dart';

enum RecipeCategory { meal, snack, beverage, dessert }

class AiService {
  LlmInferenceEngine? _engine;
  bool _isLoaded = false;
  Future<void>? _initFuture;
  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();

  bool get isOnlineMode => _isOnlineMode;
  bool _isOnlineMode = false;

  String get brainName {
    if (_isOnlineMode) return 'Online Brain (Qwen 2.5)';
    if (_isLoaded) return 'Local Brain (Gemma 2B)';
    return 'Scrappy Chef Logic';
  }

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

  Future<List<RecipeModel>> generateRecipes(
    List<PantryItem> items, {
    RecipeCategory category = RecipeCategory.meal,
    String? mealType,
    int count = 3,
  }) async {
    // Check connectivity first to decide path
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnlineMode = connectivityResult == ConnectivityResult.mobile || 
                    connectivityResult == ConnectivityResult.wifi || 
                    connectivityResult == ConnectivityResult.ethernet;

    if (_isOnlineMode) {
      debugPrint('AiService: Internet detected. Preferring Online AI (OpenRouter).');
      final onlineResults = await _generateOnlineRecipes(items, category: category, mealType: mealType, count: count);
      if (onlineResults.isNotEmpty) return onlineResults;
      debugPrint('AiService: Online generation failed or empty. Falling back to Local Brain.');
    }

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
      2. A brief 'Additional Needed Ingredients'
      3. A Difficulty level (Easy, Medium, Hard)
      4. Estimated Time in minutes
      5. Precise preparation steps, organized into TITLED SECTIONS.
      
      Format each recipe separately as:
      ---RECIPE START---
      ID: [Unique Short ID]
      RECIPE: [Name]
      DIFFICULTY: [Easy|Medium|Hard]
      TIME: [Minutes]
      ADDITIONAL NEEDED INGREDIENTS: [Proposed 1-2 extra ingredients]
      INGREDIENTS: [List of available ingredients used]
      STEPS:
      STEP TITLE: [PHASE NAME, e.g., Preparation]
      STEP DETAILS: [Detail 1], [Detail 2]
      STEP TITLE: [PHASE NAME, e.g., Cooking]
      STEP DETAILS: [Detail 1], [Detail 2]
      ---RECIPE END---
    """;

    try {
      final responseStream = _engine!.generateResponse(prompt);
      final fullResponse = await responseStream.join('');
      
      final parts = fullResponse.split('---RECIPE START---')
          .where((p) => p.contains('---RECIPE END---'))
          .map((p) => p.split('---RECIPE END---').first.trim())
          .toList();
          
      if (parts.isEmpty) {
        return _getFallbackRecipes(items);
      }

      final results = parts.map((p) {
        final id = _getPart(p, 'ID:');
        final name = _getPart(p, 'RECIPE:');
        final difficulty = _getPart(p, 'DIFFICULTY:');
        final timeStr = _getPart(p, 'TIME:');
        final upgrade = _getPart(p, 'ADDITIONAL NEEDED INGREDIENTS:');
        
        final steps = <RecipeStep>[];
        final stepSections = p.split('STEP TITLE:').skip(1);
        for (var section in stepSections) {
          final title = section.split('STEP DETAILS:').first.trim();
          final detailsPart = section.contains('STEP DETAILS:') 
            ? section.split('STEP DETAILS:').last.split('STEP TITLE:').first.trim() 
            : '';
          final details = detailsPart.split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
          if (title.isNotEmpty) {
            steps.add(RecipeStep(title: title, details: details));
          }
        }

        // Auto-save logic: Every generated dish is automatically saved to the recipe book
        final model = RecipeModel(
          id: id.isNotEmpty ? id : Uuid().v4(),
          name: name,
          upgrade: upgrade,
          ingredients: items,
          steps: steps,
          time: int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 15,
          difficulty: difficulty.isNotEmpty ? difficulty : 'Easy',
        );

        _autoSaveRecipe(model);

        return model;
      }).toList();

      return results;
    } on ArgumentError catch (e) {
      debugPrint('AiService: Native FFI Error during generation: $e');
      return _getFallbackRecipes(items);
    } catch (e) {
      debugPrint('Multi-recipe generation failed: $e');
      return _getFallbackRecipes(items);
    }
  }
  Future<List<RecipeModel>> _generateOnlineRecipes(
    List<PantryItem> items, {
    required RecipeCategory category,
    String? mealType,
    int count = 3,
  }) async {
    try {
      final prompt = _buildPrompt(items, category, mealType, count);

      final response = await _dio.post(
        ApiConfig.openRouterUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConfig.openRouterApiKey}',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://github.com/japhetcordova/PILO',
            'X-Title': 'PILO AI',
          },
        ),
        data: {
          'model': ApiConfig.qwenModel,
          'messages': [
            {'role': 'system', 'content': 'You are a professional culinary AI.'},
            {'role': 'user', 'content': prompt},
          ],
        },
      );

      final String fullResponse = response.data['choices'][0]['message']['content'];
      return _parseRecipes(fullResponse, items);
    } catch (e) {
      debugPrint('AiService: Online generation error: $e');
      return [];
    }
  }

  String _buildPrompt(List<PantryItem> items, RecipeCategory category, String? mealType, int count) {
    final itemNames = items.map((e) => e.name).join(', ');
    final categoryName = category.name.toUpperCase();
    final mealContext = mealType != null ? "This is specifically for a $mealType meal." : "";

    return """
      Based on: $itemNames, provide exactly $count distinct $categoryName recipes.
      $mealContext
      
      Format each recipe separately as:
      ---RECIPE START---
      ID: [Unique Short ID]
      RECIPE: [Name]
      DIFFICULTY: [Easy|Medium|Hard]
      TIME: [Minutes]
      ADDITIONAL NEEDED INGREDIENTS: [Proposed 1-2 extra ingredients]
      INGREDIENTS: [List of available ingredients used]
      STEPS:
      STEP TITLE: [PHASE NAME]
      STEP DETAILS: [Detail 1], [Detail 2]
      ---RECIPE END---
    """;
  }

  List<RecipeModel> _parseRecipes(String fullResponse, List<PantryItem> items) {
    final parts = fullResponse.split('---RECIPE START---')
        .where((p) => p.contains('---RECIPE END---'))
        .map((p) => p.split('---RECIPE END---').first.trim())
        .toList();

    return parts.map((p) {
      final id = _getPart(p, 'ID:');
      final name = _getPart(p, 'RECIPE:');
      final difficulty = _getPart(p, 'DIFFICULTY:');
      final timeStr = _getPart(p, 'TIME:');
      final upgrade = _getPart(p, 'ADDITIONAL NEEDED INGREDIENTS:');
      
      final steps = <RecipeStep>[];
      final stepSections = p.split('STEP TITLE:').skip(1);
      for (var section in stepSections) {
        final title = section.split('STEP DETAILS:').first.trim();
        final detailsPart = section.contains('STEP DETAILS:') 
          ? section.split('STEP DETAILS:').last.split('STEP TITLE:').first.trim() 
          : '';
        final details = detailsPart.split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
        if (title.isNotEmpty) {
          steps.add(RecipeStep(title: title, details: details));
        }
      }

      final model = RecipeModel(
        id: id.isNotEmpty ? id : Uuid().v4(),
        name: name,
        upgrade: upgrade,
        ingredients: items,
        steps: steps,
        time: int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 15,
        difficulty: difficulty.isNotEmpty ? difficulty : 'Easy',
      );

      _autoSaveRecipe(model);
      return model;
    }).toList();
  }

  void _autoSaveRecipe(RecipeModel model) async {
    try {
      final box = Hive.box<RecipeBookItem>('recipe_book');
      final item = RecipeBookItem.fromModel(model);
      await box.put(item.id, item);
      debugPrint('AiService: Auto-saved ${model.name} to Recipe Book.');
    } catch (e) {
      debugPrint('AiService: Failed to auto-save recipe: $e');
    }
  }

  String _getPart(String p, String marker) {
    if (!p.contains(marker)) return '';
    final start = p.indexOf(marker) + marker.length;
    final end = _findNextMarker(p, start);
    return p.substring(start, end).trim();
  }

  int _findNextMarker(String p, int start) {
    final markers = ['ID:', 'RECIPE:', 'DIFFICULTY:', 'TIME:', 'ADDITIONAL NEEDED INGREDIENTS:', 'INGREDIENTS:', 'STEPS:', '---RECIPE END---'];
    int next = p.length;
    for (var m in markers) {
      final idx = p.indexOf(m, start);
      if (idx != -1 && idx < next) next = idx;
    }
    return next;
  }

  List<RecipeModel> _getFallbackRecipes(List<PantryItem> items) {
    if (items.isEmpty) {
      return [];
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

    final results = matches.take(3).map((r) => r.toRecipeModel(items)).toList();

    if (results.isEmpty) {
      // Absolute fallback if no categories match (unlikely)
      return [
        RecipeModel(
          id: Uuid().v4(),
          name: "Chef's Pantry Surprise",
          upgrade: "A touch of salt and high heat.",
          ingredients: items,
          steps: [
            RecipeStep(title: "Prep", details: ["Gather all ingredients."]),
            RecipeStep(title: "Cook", details: ["Sauté everything together until aromatic."]),
            RecipeStep(title: "Serve", details: ["Serve immediately."]),
          ],
          time: 10,
          difficulty: 'Easy',
        )
      ];
    }

    return results;
  }
}
