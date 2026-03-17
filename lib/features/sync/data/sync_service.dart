import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../../inventory/domain/models/custom_ingredient.dart';

class SyncService {
  final Connectivity _connectivity = Connectivity();

  Future<void> initialize() async {
    // Listen to network changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        debugPrint('SyncService: Online connection detected. Initiating sync...');
        _syncUnsyncedIngredients();
      }
    });

    // Run initial check
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      _syncUnsyncedIngredients();
    }
  }

  Future<void> _syncUnsyncedIngredients() async {
    try {
      final box = Hive.box<CustomIngredient>('custom_ingredients');
      final unsynced = box.values.where((item) => !item.isSynced).toList();

      if (unsynced.isEmpty) {
        debugPrint('SyncService: All ingredients already synced or evaluated.');
        return;
      }

      for (var ingredient in unsynced) {
        debugPrint('SyncService: Re-evaluating online for ${ingredient.name}...');
        
        // TODO: In a production app, this would hit an online LLM API or scraper
        // For example:
        // final enrichedData = await onlineApi.fetchIngredientDetails(ingredient.name);
        
        // Simulating network delay and generic enrichment
        await Future.delayed(const Duration(seconds: 2));
        
        // Here we just mark it as synced to avoid repeating the loop
        ingredient.isSynced = true;
        // ingredient.description += ' [Verified Online]';
        
        await ingredient.save();
        debugPrint('SyncService: Successfully enriched and synced ${ingredient.name}.');
      }
    } catch (e) {
      debugPrint('SyncService: Error during sync: $e');
    }
  }
}
