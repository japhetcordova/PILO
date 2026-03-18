import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:connectivity_plus/connectivity_plus.dart';

class BrainDownloader {
  static const String modelUrl = 
      'https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/resolve/main/Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task';
  
  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, 'pilo_brain.task');
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

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      onError('No internet connection. Please connect to a network to download Pilo\'s brain.');
      return;
    }

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
      if (e.response?.statusCode == 404 || e.type == DioExceptionType.badResponse) {
        onError('The AI model file is currently unavailable for direct download. '
                'Google has gated these models behind Kaggle. '
                'Please use "Manual Import" or follow the Kaggle link below!');
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        onError('Download timed out. Please check your internet connection and try again.');
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
