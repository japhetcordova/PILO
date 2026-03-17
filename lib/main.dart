import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/inventory/presentation/inventory_screen.dart';
import 'features/inventory/presentation/onboarding_screen.dart';
import 'features/inventory/domain/models/pantry_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  await Hive.initFlutter();
  Hive.registerAdapter(PantryItemAdapter());
  await Hive.openBox<PantryItem>('pantry_items');
  await Hive.openBox('user_settings');

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
