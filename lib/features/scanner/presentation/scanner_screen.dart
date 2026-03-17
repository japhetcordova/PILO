import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import '../data/vision_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  final VisionService _visionService = VisionService();
  bool _isProcessing = false;
  List<DetectedObject> _objects = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    _visionService.initialize();
    
    _controller!.startImageStream((image) {
      if (_isProcessing) return;
      _processImage(image);
    });

    if (mounted) setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    _isProcessing = true;
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          _buildOverlay(),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _buildCaptureControl(),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      painter: ObjectDetectorPainter(_objects),
    );
  }

  Widget _buildCaptureControl() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: const Text(
        'PILO IS SEARCHING...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _visionService.dispose();
    super.dispose();
  }
}

class ObjectDetectorPainter extends CustomPainter {
  final List<DetectedObject> objects;
  ObjectDetectorPainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color(0xFFFF5722);

    for (var object in objects) {
      canvas.drawRect(object.boundingBox, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
