import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../recipe/presentation/ai_provider.dart';
import '../../recipe/data/brain_downloader.dart';
import 'inventory_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  double _progress = 0;
  bool _isDownloading = false;
  String _downloadMessage = 'Pilo is setting up his chef hat...';

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) return;

    final box = Hive.box('user_settings');
    await box.put('user_name', _nameController.text.trim());
    await box.put('is_onboarded', true);

    // Check if brain is already downloaded
    final isDownloaded = await BrainDownloader.isBrainDownloaded();
    
    if (isDownloaded) {
      _navigateToMain();
    } else {
      setState(() {
        _isDownloading = true;
      });

      try {
        await BrainDownloader.downloadBrain(
          onProgress: (p) => setState(() => _progress = p),
          onComplete: () => _navigateToMain(),
          onError: (e) {
            setState(() {
              _isDownloading = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pilo got a headache: $e')),
              );
            });
          },
        );
      } catch (e) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _importManually() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // .bin files might not be recognized as a specific type
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isDownloading = true;
          _progress = 0.5; // Visual feedback
          _downloadMessage = 'Pilo is importing your hand-carried brain...';
        });

        await BrainDownloader.importBrain(result.files.single.path!);
        
        setState(() => _progress = 1.0);
        _navigateToMain();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  void _navigateToMain() {
    // Eagerly initialize AI Service now that the brain is ready
    ref.read(aiServiceProvider);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InventoryScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/images/pilo_pixel.png', width: 120, height: 120),
              ),
              const SizedBox(height: 40),
              if (!_isDownloading) ...[
                Text(
                  'Mabuhay, Chef!',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Im Pilo, your pocket chef. What should I call you?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.outfit(fontSize: 18, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveName,
                  child: const Text('LET\'S START COOKING'),
                ),
              ] else ...[
                Text(
                  'PILO IS LEARNING...',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Setting up your offline kitchen brain (1.3GB)',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 48),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  _downloadMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 32),
                // Fallback options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _importManually(),
                      icon: const Icon(Icons.file_upload_outlined, size: 20),
                      label: const Text('IMPORT MANUALLY'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                         // link previously provided in conversation
                      },
                      child: const Text('KAGGLE LINK'),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
