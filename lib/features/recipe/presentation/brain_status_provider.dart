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
    state = await BrainDownloader.isBrainDownloaded();
  }

  void setDownloaded(bool value) {
    state = value;
  }
}
