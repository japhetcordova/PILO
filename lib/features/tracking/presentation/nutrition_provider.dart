import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/meal_record.dart';
import 'meal_providers.dart';

class NutritionStats {
  final int go;
  final int grow;
  final int glow;

  NutritionStats({required this.go, required this.grow, required this.glow});

  double get total => (go + grow + glow).toDouble();
  
  double get goPercentage => total > 0 ? go / total : 0.0;
  double get growPercentage => total > 0 ? grow / total : 0.0;
  double get glowPercentage => total > 0 ? glow / total : 0.0;
}

final weeklyNutritionStatsProvider = Provider<NutritionStats>((ref) {
  final records = ref.watch(mealRecordsProvider);
  final now = DateTime.now();
  final lastWeek = now.subtract(const Duration(days: 7));

  int go = 0;
  int grow = 0;
  int glow = 0;

  for (MealRecord record in records) {
    if (record.date.isAfter(lastWeek)) {
      go += record.goCount;
      grow += record.growCount;
      glow += record.glowCount;
    }
  }

  return NutritionStats(go: go, grow: grow, glow: glow);
});

final mascotNutritionTipProvider = Provider<String>((ref) {
  final stats = ref.watch(weeklyNutritionStatsProvider);
  
  if (stats.total == 0) {
    return "Pilo is hungry for data! Log your meals so I can give you health tips!";
  }

  if (stats.glowPercentage < 0.2) {
    return "You need more GLOW food for healthy skin and eyes! Add some veggies to your next meal.";
  }
  
  if (stats.growPercentage < 0.2) {
    return "Time to GROW! Your muscles need more protein. Maybe some chicken or eggs?";
  }
  
  if (stats.goPercentage < 0.2) {
    return "Feeling tired? You need more GO food for energy! Try adding some rice or bread.";
  }

  if (stats.goPercentage > 0.6) {
    return "Lots of energy! But don't forget your vegetables (GLOW) to stay balanced.";
  }

  return "You're eating a great balance of food! Keep it up, Chef!";
});
