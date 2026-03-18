class LocalRecipe {
  final String name;
  final String upgrade;
  final List<String> steps;
  final List<String> requiredCategories; // e.g., ['grow', 'glow']
  final int time;

  const LocalRecipe({
    required this.name,
    required this.upgrade,
    required this.steps,
    required this.requiredCategories,
    required this.time,
  });

  String toFormattedString(List<String> availableIngredients) {
    return """
RECIPE: $name
CHEF'S UPGRADE: $upgrade
INGREDIENTS: ${availableIngredients.join(', ')}
STEPS: 
${steps.asMap().entries.map((e) => "${e.key + 1}. ${e.value}").join('\n')}
TIME: $time
""";
  }
}

const List<LocalRecipe> curatedRecipes = [
  LocalRecipe(
    name: "Professional Sautéed Medley",
    upgrade: "A splash of white wine or apple cider vinegar to deglaze the pan.",
    requiredCategories: ['glow'],
    steps: [
      "Wash and precisely dice all available GLOW ingredients.",
      "Heat a skillet with high-quality oil over medium-high heat.",
      "Sauté ingredients until vibrant and tender-crisp.",
      "Deglaze with your upgrade and season with sea salt."
    ],
    time: 12,
  ),
  LocalRecipe(
    name: "High-Protein Power Bowl",
    upgrade: "Toasted sesame seeds or a drizzle of tahini for nutty complexity.",
    requiredCategories: ['grow', 'glow'],
    steps: [
      "Prepare your GROW proteins and GLOW vegetables separately.",
      "Sear the proteins until golden brown and fully cooked.",
      "Steam or lightly sauté the vegetables to preserve nutrients.",
      "Combine in a bowl, add your upgrade, and serve warm."
    ],
    time: 20,
  ),
  LocalRecipe(
    name: "Chef's Energy Skillet",
    upgrade: "A pinch of smoked paprika or cumin for a deep, earthy aroma.",
    requiredCategories: ['go', 'grow'],
    steps: [
      "Dice GO carbohydrates (potatoes/grains) into uniform cubes.",
      "Crisp the carbohydrates in a hot pan until golden.",
      "Add GROW proteins and cook until tender.",
      "Fold in spices and your upgrade during the final 2 minutes."
    ],
    time: 15,
  ),
  LocalRecipe(
    name: "The Complete Balanced Plate",
    upgrade: "Freshly grated ginger or garlic sautéed at the very start.",
    requiredCategories: ['go', 'grow', 'glow'],
    steps: [
      "Start by aromatics (upgrade) in a large pan.",
      "Add GO and GROW ingredients and sear for 5 minutes.",
      "Toss in GLOW vegetables and cover to lightly steam.",
      "Season with cracked black pepper and serve beautifully."
    ],
    time: 25,
  ),
];
