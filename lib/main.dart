import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/inventory/presentation/inventory_screen.dart';
import 'features/inventory/presentation/onboarding_screen.dart';
import 'features/inventory/domain/models/pantry_item.dart';
import 'features/inventory/domain/models/custom_ingredient.dart';
import 'features/tracking/domain/models/meal_record.dart';
import 'features/tracking/domain/models/water_log.dart';
import 'features/sync/data/sync_service.dart';
import 'features/inventory/presentation/settings_provider.dart';
import 'shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  await Hive.initFlutter();
  Hive.registerAdapter(NutritionalCategoryAdapter());
  Hive.registerAdapter(PantryItemAdapter());
  Hive.registerAdapter(CustomIngredientAdapter());
  Hive.registerAdapter(MealRecordAdapter());
  Hive.registerAdapter(WaterLogAdapter());

  // Safe box initialization with automatic self-healing
  await _safeOpenBox<PantryItem>('pantry_items');
  await _safeOpenBox<CustomIngredient>('custom_ingredients');
  await _safeOpenBox<MealRecord>('meal_records');
  await _safeOpenBox<WaterLog>('water_logs');
  await _safeOpenBox('user_settings');

  // Initialize Sync Service for online enrichment
  final syncService = SyncService();
  await syncService.initialize();

  runApp(
    const ProviderScope(
      child: PiloApp(),
    ),
  );
}

class PiloApp extends ConsumerWidget {
  const PiloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingBox = Hive.box('user_settings');
    final isOnboarded = onboardingBox.get('is_onboarded', defaultValue: false);
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));

    return MaterialApp(
      title: 'Pilo AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: isOnboarded ? const MainShell() : const OnboardingScreen(),
    );
  }
}

/// Helper to safely open Hive boxes and automatically delete them if they are corrupted
/// or have incompatible schemas from previous versions.
Future<void> _safeOpenBox<T>(String name) async {
  try {
    await Hive.openBox<T>(name);
  } catch (e) {
    debugPrint('Storage Error ($name): $e. Attempting self-healing...');
    try {
      // Sometimes the box file is locked or corrupted, delete and retry
      await Hive.deleteBoxFromDisk(name);
    } catch (err) {
      debugPrint('Self-healing failed to delete box ($name): $err');
    }
    await Hive.openBox<T>(name);
  }
}
