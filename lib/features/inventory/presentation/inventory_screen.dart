import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pantry_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../scanner/presentation/scanner_screen.dart';
import '../../recipe/presentation/recipe_decision_screen.dart';
import '../../recipe/data/brain_downloader.dart';
import '../../recipe/presentation/brain_status_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(pantryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PILO — KUSINA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {}, 
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PiloGreetingCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'YOUR PANTRY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset('assets/images/pilo_pixel.png', width: 100, height: 100),
                        ),
                        const SizedBox(height: 16),
                        const Text('Your pantry looks lonely.'),
                        const Text('Scan items and Pilo will find a recipe!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _PantryItemCard(item: item);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecipeDecisionScreen()),
                  ),
                  child: const Text('ASK PILO FOR A MEAL'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScannerScreen()),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('SCAN WITH PILO'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PiloGreetingCard extends StatelessWidget {
  const _PiloGreetingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset('assets/images/pilo_pixel.png', width: 48, height: 48),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, ${Hive.box('user_settings').get('user_name', defaultValue: 'Chef')}!',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'What can Pilo cook for you today?',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PantryItemCard extends StatelessWidget {
  final dynamic item;
  const _PantryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.restaurant, size: 24, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            item.name.toUpperCase(),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'In stock',
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

