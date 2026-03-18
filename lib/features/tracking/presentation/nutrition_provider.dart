import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/meal_record.dart';
import 'meal_providers.dart';

class NutritionStats {
  final int go;
  final int grow;
  final int glow;
  final int totalMeals;

  NutritionStats({required this.go, required this.grow, required this.glow, required this.totalMeals});

  // Percentage calculations relative to balanced target (1/3 each)
  // Or simply normalized to the total counts if we want to show share
  double get totalCount => (go + grow + glow).toDouble();
  
  double get goPercentage => totalCount > 0 ? go / totalCount : 0.0;
  double get growPercentage => totalCount > 0 ? grow / totalCount : 0.0;
  double get glowPercentage => totalCount > 0 ? glow / totalCount : 0.0;
}

final weeklyNutritionStatsProvider = Provider<NutritionStats>((ref) {
  final records = ref.watch(mealRecordsProvider);
  final now = DateTime.now();
  // Filter for last 7 days, including today
  final startOfRange = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));

  int go = 0;
  int grow = 0;
  int glow = 0;
  int totalMeals = 0;

  for (MealRecord record in records) {
    if (record.date.isAfter(startOfRange)) {
      go += record.goCount;
      grow += record.growCount;
      glow += record.glowCount;
      totalMeals++;
    }
  }

  return NutritionStats(go: go, grow: grow, glow: glow, totalMeals: totalMeals);
});

final mascotNutritionTipProvider = Provider<String>((ref) {
  final stats = ref.watch(weeklyNutritionStatsProvider);
  
  if (stats.totalMeals == 0) {
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
