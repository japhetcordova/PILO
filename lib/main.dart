import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/inventory/presentation/inventory_screen.dart';
import 'features/inventory/domain/models/pantry_item.dart';
import 'features/inventory/domain/models/pantry_item.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  await Hive.initFlutter();
  Hive.registerAdapter(PantryItemAdapter());
  await Hive.openBox<PantryItem>('pantry_items');

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
    return MaterialApp(
      title: 'Pilo AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const InventoryScreen(),
    );
  }
}
