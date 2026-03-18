import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/inventory/presentation/inventory_screen.dart';
import '../features/recipe/presentation/recipe_decision_screen.dart';
import '../features/tracking/presentation/track_tab.dart';
import '../features/inventory/presentation/settings_screen.dart';
import '../features/manual_input/presentation/manual_input_screen.dart';
import '../features/recipe/presentation/meal_selection_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const InventoryScreen(), // We'll rename this to HomeTab internally later, or just keep the class name
    const MealSelectionScreen(),
    const TrackTab(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddIngredientSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: const ManualInputScreen(isModal: true),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIngredientSheet,
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: BottomAppBar(
                  elevation: 0,
                  color: Colors.transparent,
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 8,
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_filled, Icons.home_outlined, 'Home'),
                      _buildNavItem(1, Icons.restaurant_menu, Icons.restaurant_menu_outlined, 'Recipes'),
                      const SizedBox(width: 56), // Space for FAB
                      _buildNavItem(2, Icons.bar_chart, Icons.bar_chart_outlined, 'Track'),
                      _buildNavItem(3, Icons.person, Icons.person_outline, 'Profile'),
                    ],
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? Theme.of(context).colorScheme.primary 
        : Colors.grey.withOpacity(0.6);

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
