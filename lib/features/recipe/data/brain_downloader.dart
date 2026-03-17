import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class BrainDownloader {
  static const String modelUrl = 
      'https://storage.googleapis.com/mediapipe-models/llm_inference/gemma-2b-it-gpu-int4/float16/1/gemma-2b-it-gpu-int4.bin';
  
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        onError('Brain server is unreachable (404). Please use "Manual Import" for now!');
      } else {
        onError('Download failed: ${e.message}');
      }
    } catch (e) {
      onError('An unexpected error occurred: $e');
    }
  }

  static Future<void> importBrain(String sourcePath) async {
    final destinationPath = await localPath;
    final sourceFile = File(sourcePath);
    await sourceFile.copy(destinationPath);
  }

  static Future<void> deleteBrain() async {
    final path = await localPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
