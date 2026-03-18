import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/brain_downloader.dart';

final brainStatusProvider = StateNotifierProvider<BrainStatusNotifier, bool>((ref) {
  return BrainStatusNotifier();
});

class BrainStatusNotifier extends StateNotifier<bool> {
  BrainStatusNotifier() : super(false) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final isDownloaded = await BrainDownloader.isBrainDownloaded();
    
    // Check if the architecture is supported (MediaPipe GenAI doesn't support x86/x64).
    final isSupported = !Platform.version.toLowerCase().contains('x86') && 
                       !Platform.version.toLowerCase().contains('x64');
    
    state = isDownloaded && isSupported;
  }

  void setDownloaded(bool value) {
    state = value;
  }

  Future<void> refresh() async {
    await checkStatus();
  }
}
