import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/vision_service.dart';
import '../../inventory/presentation/pantry_providers.dart';
import '../../inventory/domain/models/pantry_item.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  CameraController? _controller;
  final VisionService _visionService = VisionService();
  bool _isProcessing = false;
  DateTime? _lastProcessedTime;
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
    if (_isProcessing) return;
    
    // Throttle to 1 frame every 500ms
    final currentTime = DateTime.now();
    if (_lastProcessedTime != null && 
        currentTime.difference(_lastProcessedTime!).inMilliseconds < 500) {
      return;
    }

    _isProcessing = true;
    _lastProcessedTime = currentTime;

    try {
      final inputImage = _visionService.convertCameraImage(image, _controller!.description);
      if (inputImage != null) {
        final objects = await _visionService.processImage(inputImage);
        if (mounted) {
          setState(() {
            _objects = objects;
          });
        }
      }
    } catch (e) {
      debugPrint('Vision Error: $e');
    } finally {
      _isProcessing = false;
    }
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
            bottom: 120,
            left: 20,
            right: 20,
            child: _buildCaptureControl(),
          ),
          _buildSightingsSheet(),
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

  Widget _buildSightingsSheet() {
    final sightings = _objects
        .where((obj) => obj.labels.isNotEmpty)
        .map((obj) => obj.labels.first.text)
        .toSet()
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined, color: Colors.black54),
                    SizedBox(width: 12),
                    Text(
                      'PILO HAS SEEN...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sightings.isEmpty
                    ? const Center(child: Text('Scanning for ingredients...'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: sightings.length,
                        itemBuilder: (context, index) {
                          final name = sightings[index];
                          return _SightingTile(name: name);
                        },
                      ),
              ),
            ],
          ),
        );
      },
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.2),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Image.asset('assets/images/pilo_normal.png', width: 40, height: 40),
              );
            },
            onEnd: () {}, // Handled by repeating via a state if needed, but for now we'll use a simpler persistent pulse
          ),
          const SizedBox(width: 16),
          _PulsingText(),
        ],
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

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var object in objects) {
      canvas.drawRect(object.boundingBox, paint);

      if (object.labels.isNotEmpty) {
        final label = object.labels.first;
        textPainter.text = TextSpan(
          text: '${label.text} (${(label.confidence * 100).toInt()}%)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0xFFFF5722),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(object.boundingBox.left, object.boundingBox.top - 20),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PulsingText extends StatefulWidget {
  const _PulsingText({super.key});

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Text(
        'PILO IS SEARCHING...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SightingTile extends ConsumerStatefulWidget {
  final String name;

  const _SightingTile({required this.name});

  @override
  ConsumerState<_SightingTile> createState() => _SightingTileState();
}

class _SightingTileState extends ConsumerState<_SightingTile> {
  bool _added = false;

  void _add() {
    if (_added) return;
    final item = PantryItem(
      id: const Uuid().v4(),
      name: widget.name,
      dateAdded: DateTime.now(),
    );
    ref.read(pantryItemsProvider.notifier).addItem(item);
    setState(() => _added = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.name.toUpperCase()} to pantry!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _added ? Colors.green.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _added ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _added ? Colors.green : Colors.orange,
            radius: 16,
            child: Icon(
              _added ? Icons.check : Icons.restaurant,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: _added ? null : _add,
            child: Text(_added ? 'ADDED' : 'ADD'),
          ),
        ],
      ),
    );
  }
}
