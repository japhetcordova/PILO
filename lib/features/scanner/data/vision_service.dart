import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class VisionService {
  late ObjectDetector _objectDetector;
  bool _isInitialized = false;

  Future<void> initialize() async {
    const mode = DetectionMode.stream;
    final options = ObjectDetectorOptions(
      mode: mode,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
    _isInitialized = true;
  }

  Future<List<DetectedObject>> processImage(InputImage inputImage) async {
    if (!_isInitialized) await initialize();
    return await _objectDetector.processImage(inputImage);
  }

  void dispose() {
    _objectDetector.close();
  }
}
