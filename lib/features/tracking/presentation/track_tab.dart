import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'nutrition_dashboard_screen.dart';
import 'meal_calendar_screen.dart';

class TrackTab extends StatelessWidget {
  const TrackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TRACKING'),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'NUTRITION'),
              Tab(text: 'CALENDAR'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NutritionDashboardScreen(),
            MealCalendarScreen(),
          ],
        ),
      ),
    );
  }
}
