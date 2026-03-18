import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../recipe/presentation/brain_status_provider.dart';
import '../../recipe/data/brain_downloader.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 32),
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
          _buildSectionHeader('AI BRAIN'),
          _buildPiloBrainTile(context, ref),
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
              'Pilo AI v1.1.0\nMade with <3 for Chefs',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final name = Hive.box('user_settings').get('user_name', defaultValue: 'Chef');
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Home Cook',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Clear All Data?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will delete all your ingredients, meal history, and water streaks. This action cannot be undone.'),
              const SizedBox(height: 16),
              const Text('Type "DELETE" to confirm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'DELETE',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            TextButton(
              onPressed: controller.text == 'DELETE' 
                ? () async {
                    await ref.read(settingsProvider.notifier).clearAllData();
                    if (context.mounted) Navigator.pop(context);
                  }
                : null,
              child: Text(
                'DELETE EVERYTHING', 
                style: TextStyle(color: controller.text == 'DELETE' ? Colors.redAccent : Colors.grey)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPiloBrainTile(BuildContext context, WidgetRef ref) {
    final isDownloaded = ref.watch(brainStatusProvider);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDownloaded ? Colors.green : Colors.orange).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isDownloaded ? Icons.psychology : Icons.psychology_outlined,
          color: isDownloaded ? Colors.green : Colors.orange,
          size: 20,
        ),
      ),
      title: Text('Pilo Brain (Offline AI)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      subtitle: FutureBuilder<bool>(
        future: BrainDownloader.isBrainDownloaded(),
        builder: (context, snapshot) {
          final fileExists = snapshot.data ?? false;
          final isReady = ref.watch(brainStatusProvider);
          
          String statusText;
          Color statusColor;
          
          if (isReady) {
            statusText = 'Status: READY (350MB)';
            statusColor = Colors.green;
          } else if (fileExists) {
            statusText = 'Status: DOWNLOADED (Unsupported on this device)';
            statusColor = Colors.orange;
          } else {
            statusText = 'Status: MISSING (Requires setup)';
            statusColor = Colors.orange;
          }
          
          return Text(
            statusText,
            style: GoogleFonts.outfit(fontSize: 12, color: statusColor),
          );
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
        onPressed: () => ref.read(brainStatusProvider.notifier).refresh(),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, WidgetRef ref) {
    double progress = 0;
    String? error;
    bool isComplete = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Downloading Pilo Brain', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red, fontSize: 13))
              else if (isComplete)
                const Text('Download complete! Pilo is now smarter.')
              else ...[
                const Text('Fetching 1.3GB of culinary knowledge...', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 8),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]
            ],
          ),
          actions: [
            if (error != null || isComplete)
              TextButton(
                onPressed: () {
                  ref.read(brainStatusProvider.notifier).refresh();
                  Navigator.pop(context);
                },
                child: const Text('CLOSE'),
              )
            else
              TextButton(
                onPressed: () {
                   BrainDownloader.downloadBrain(
                     onProgress: (p) => setState(() => progress = p),
                     onComplete: () => setState(() => isComplete = true),
                     onError: (e) => setState(() => error = e),
                   );
                },
                child: const Text('START'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleManualImport(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        await BrainDownloader.importBrain(result.files.single.path!);
        await ref.read(brainStatusProvider.notifier).refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilo Brain imported successfully!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }
}
