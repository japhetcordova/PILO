import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final ThemeMode themeMode;
  final bool showMascotTips;
  final String mascotName;

  SettingsState({
    required this.themeMode,
    required this.showMascotTips,
    required this.mascotName,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? showMascotTips,
    String? mascotName,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      showMascotTips: showMascotTips ?? this.showMascotTips,
      mascotName: mascotName ?? this.mascotName,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(
    themeMode: ThemeMode.system,
    showMascotTips: true,
    mascotName: 'Pilo',
  )) {
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box('user_settings');
    final themeIndex = box.get('theme_mode', defaultValue: 0);
    final showTips = box.get('show_mascot_tips', defaultValue: true);
    final name = box.get('mascot_name', defaultValue: 'Pilo');

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      showMascotTips: showTips,
      mascotName: name,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final box = Hive.box('user_settings');
    await box.put('theme_mode', mode.index);
  }

  Future<void> toggleMascotTips(bool value) async {
    state = state.copyWith(showMascotTips: value);
    final box = Hive.box('user_settings');
    await box.put('show_mascot_tips', value);
  }
  
  Future<void> clearAllData() async {
     await Hive.box('pantry_items').clear();
     await Hive.box('meal_records').clear();
     await Hive.box('water_logs').clear();
     await Hive.box('custom_ingredients').clear();
  }
}
