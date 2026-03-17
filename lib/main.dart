import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/inventory/presentation/inventory_screen.dart';
import 'features/inventory/presentation/onboarding_screen.dart';
import 'features/inventory/domain/models/pantry_item.dart';
import 'features/inventory/domain/models/custom_ingredient.dart';
import 'features/tracking/domain/models/meal_record.dart';
import 'features/sync/data/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  await Hive.initFlutter();
  Hive.registerAdapter(NutritionalCategoryAdapter());
  Hive.registerAdapter(PantryItemAdapter());
  Hive.registerAdapter(CustomIngredientAdapter());
  Hive.registerAdapter(MealRecordAdapter());

  // Delete corrupted boxes if migration fails during development
  try {
    await Hive.openBox<PantryItem>('pantry_items');
  } catch (e) {
    debugPrint('Hive Box Error: $e. Clearing box...');
    try {
      await Hive.deleteBoxFromDisk('pantry_items');
    } catch (err) {
      debugPrint('Force clearing failed: $err');
    }
    await Hive.openBox<PantryItem>('pantry_items');
  }
  
  await Hive.openBox<CustomIngredient>('custom_ingredients');
  await Hive.openBox<MealRecord>('meal_records');
  await Hive.openBox('user_settings');

  // Initialize Sync Service for online enrichment
  final syncService = SyncService();
  await syncService.initialize();

  runApp(
    const ProviderScope(
      child: PiloApp(),
    ),
  );
}

class PiloApp extends StatelessWidget {
  const PiloApp({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingBox = Hive.box('user_settings');
    final isOnboarded = onboardingBox.get('is_onboarded', defaultValue: false);

    return MaterialApp(
      title: 'Pilo AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: isOnboarded ? const InventoryScreen() : const OnboardingScreen(),
    );
  }
}
