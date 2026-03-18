import 'package:pilo/features/inventory/domain/models/pantry_item.dart';
import 'package:pilo/features/recipe/domain/models/recipe_model.dart';

import 'package:uuid/uuid.dart';

class LocalRecipe {
  final String name;
  final String upgrade;
  final List<RecipeStep> steps;
  final List<String> requiredCategories; // e.g., ['grow', 'glow']
  final int time;
  final String difficulty;

  const LocalRecipe({
    required this.name,
    required this.upgrade,
    required this.steps,
    required this.requiredCategories,
    required this.time,
    this.difficulty = 'Easy',
  });

  RecipeModel toRecipeModel(List<PantryItem> availableItems) {
    return RecipeModel(
      id: Uuid().v4(),
      name: name,
      upgrade: upgrade,
      ingredients: availableItems,
      steps: steps,
      time: time,
      difficulty: difficulty,
    );
  }
}

const List<LocalRecipe> curatedRecipes = [
  LocalRecipe(
    name: "Professional Sautéed Medley",
    upgrade: "A splash of white wine or apple cider vinegar to deglaze the pan.",
    requiredCategories: ['glow'],
    steps: [
      RecipeStep(title: "Preparation", details: ["Wash and precisely dice all available GLOW ingredients."]),
      RecipeStep(title: "Cooking", details: [
        "Heat a skillet with high-quality oil over medium-high heat.",
        "Sauté ingredients until vibrant and tender-crisp.",
        "Deglaze with your upgrade and season with sea salt."
      ]),
    ],
    time: 12,
    difficulty: "Easy",
  ),
  LocalRecipe(
    name: "High-Protein Power Bowl",
    upgrade: "Toasted sesame seeds or a drizzle of tahini for nutty complexity.",
    requiredCategories: ['grow', 'glow'],
    steps: [
      RecipeStep(title: "Searing", details: [
        "Prepare your GROW proteins and GLOW vegetables separately.",
        "Sear the proteins until golden brown and fully cooked."
      ]),
      RecipeStep(title: "Assembling", details: [
        "Steam or lightly sauté the vegetables to preserve nutrients.",
        "Combine in a bowl, add your upgrade, and serve warm."
      ]),
    ],
    time: 20,
    difficulty: "Medium",
  ),
  LocalRecipe(
    name: "Chef's Energy Skillet",
    upgrade: "A pinch of smoked paprika or cumin for a deep, earthy aroma.",
    requiredCategories: ['go', 'grow'],
    steps: [
      RecipeStep(title: "Prep & Crisp", details: [
        "Dice GO carbohydrates (potatoes/grains) into uniform cubes.",
        "Crisp the carbohydrates in a hot pan until golden."
      ]),
      RecipeStep(title: "Finish", details: [
        "Add GROW proteins and cook until tender.",
        "Fold in spices and your upgrade during the final 2 minutes."
      ]),
    ],
    time: 15,
    difficulty: "Easy",
  ),
  LocalRecipe(
    name: "The Complete Balanced Plate",
    upgrade: "Freshly grated ginger or garlic sautéed at the very start.",
    requiredCategories: ['go', 'grow', 'glow'],
    steps: [
      RecipeStep(title: "Sauté", details: [
        "Start by aromatics (upgrade) in a large pan.",
        "Add GO and GROW ingredients and sear for 5 minutes."
      ]),
      RecipeStep(title: "Steam & Serve", details: [
        "Toss in GLOW vegetables and cover to lightly steam.",
        "Season with cracked black pepper and serve beautifully."
      ]),
    ],
    time: 25,
    difficulty: "Medium",
  ),
];
