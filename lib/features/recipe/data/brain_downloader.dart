import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class BrainDownloader {
  static const String modelUrl = 
      'https://storage.googleapis.com/pilo-ai-assets/models/gemma-2b-it-cpu-int4.bin'; // Example URL
  
  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, 'pilo_brain.bin');
  }

  static Future<bool> isBrainDownloaded() async {
    final path = await localPath;
    return File(path).exists();
  }

  static Future<void> downloadBrain({
    required Function(double progress) onProgress,
    required Function() onComplete,
    required Function(String error) onError,
  }) async {
    final path = await localPath;
    final dio = Dio();

    try {
      await dio.download(
        modelUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      onComplete();
    } catch (e) {
      onError(e.toString());
    }
  }

  static Future<void> deleteBrain() async {
    final path = await localPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
