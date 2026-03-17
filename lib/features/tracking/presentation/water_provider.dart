import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/water_log.dart';

final waterLogsProvider = StateNotifierProvider<WaterLogsNotifier, List<WaterLog>>((ref) {
  return WaterLogsNotifier();
});

class WaterLogsNotifier extends StateNotifier<List<WaterLog>> {
  WaterLogsNotifier() : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    final box = Hive.box<WaterLog>('water_logs');
    state = box.values.toList();
  }

  Future<void> addGlass() async {
    final box = Hive.box<WaterLog>('water_logs');
    final now = DateTime.now();
    
    final log = WaterLog(
      id: const Uuid().v4(),
      date: now,
      glasses: 1,
    );
    
    await box.add(log);
    state = [...state, log];
  }

  int get todaysCount {
    final now = DateTime.now();
    return state.where((log) => 
      log.date.year == now.year && 
      log.date.month == now.month && 
      log.date.day == now.day
    ).length;
  }

  int get currentStreak {
    if (state.isEmpty) return 0;
    
    // Group glasses by day
    final Map<String, int> dailyTotals = {};
    for (var log in state) {
      final dayKey = "${log.date.year}-${log.date.month}-${log.date.day}";
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + log.glasses;
    }

    int streak = 0;
    DateTime checkDate = DateTime.now();
    const int goal = 8; // Glasses per day for streak

    // Check backwards from today
    while (true) {
      final dayKey = "${checkDate.year}-${checkDate.month}-${checkDate.day}";
      final total = dailyTotals[dayKey] ?? 0;
      
      if (total >= goal) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // If it's today and we haven't hit goal yet, streak might still be alive from yesterday
        if (streak == 0 && isSameDay(checkDate, DateTime.now())) {
           checkDate = checkDate.subtract(const Duration(days: 1));
           continue;
        }
        break;
      }
    }
    return streak;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
