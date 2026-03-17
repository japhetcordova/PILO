import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('APPEARANCE'),
          _buildSettingTile(
            context,
            'Theme Mode',
            'Currently: ${settings.themeMode.name.toUpperCase()}',
            Icons.palette_outlined,
            onTap: () => _showThemePicker(context, ref, settings.themeMode),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('MASCOT'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Show ${settings.mascotName}\'s Advice', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('Enable proactive nutrition tips', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            value: settings.showMascotTips,
            onChanged: (val) => ref.read(settingsProvider.notifier).toggleMascotTips(val),
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('DATA'),
          _buildSettingTile(
            context,
            'Clear All Data',
            'Delete inventory and history forever',
            Icons.delete_forever_outlined,
            color: Colors.redAccent,
            onTap: () => _showDeleteConfirmation(context, ref),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Pilo AI v1.2.0\nMade with <3 for Chefs',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SELECT THEME', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              ...ThemeMode.values.map((mode) => ListTile(
                title: Text(mode.name.toUpperCase(), style: GoogleFonts.outfit()),
                leading: Icon(
                  mode == ThemeMode.light ? Icons.light_mode : mode == ThemeMode.dark ? Icons.dark_mode : Icons.brightness_auto,
                ),
                trailing: current == mode ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all your ingredients, meal history, and water streaks. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).clearAllData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('DELETE EVERYTHING', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
