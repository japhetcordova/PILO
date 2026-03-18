import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/ai_service.dart';
import 'ingredient_input_screen.dart';

class MealSelectionScreen extends StatelessWidget {
  const MealSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> meals = [
      {'title': 'BREAKFAST', 'icon': Icons.wb_sunny_outlined, 'category': RecipeCategory.meal, 'type': 'Breakfast', 'color': Colors.orange},
      {'title': 'LUNCH', 'icon': Icons.lunch_dining_outlined, 'category': RecipeCategory.meal, 'type': 'Lunch', 'color': Colors.blue},
      {'title': 'DINNER', 'icon': Icons.nightlight_round_outlined, 'category': RecipeCategory.meal, 'type': 'Dinner', 'color': Colors.indigo},
      {'title': 'SNACK', 'icon': Icons.cookie_outlined, 'category': RecipeCategory.snack, 'type': 'Snack', 'color': Colors.brown},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('WHAT ARE YOU COOKING?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a meal type to begin',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return _MealCard(
                    title: meal['title'],
                    icon: meal['icon'],
                    color: meal['color'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IngredientInputScreen(
                            category: meal['category'],
                            mealType: meal['type'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MealCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
