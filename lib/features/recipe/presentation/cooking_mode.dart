import 'package:flutter/material.dart';

class CookingModeScreen extends StatefulWidget {
  final String recipe;
  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;
  List<String> _steps = [];

  @override
  void initState() {
    super.initState();
    _parseSteps();
  }

  void _parseSteps() {
    final stepsIndex = widget.recipe.indexOf('STEPS:');
    final timeIndex = widget.recipe.indexOf('TIME:');
    if (stepsIndex != -1) {
      final stepsPart = widget.recipe.substring(
        stepsIndex + 6,
        timeIndex != -1 ? timeIndex : widget.recipe.length,
      );
      _steps = stepsPart
          .split(RegExp(r'\d+\.'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (_steps.isEmpty) _steps = ['Follow Pilo\'s lead!'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('KUSINA MODE'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: Colors.white10,
            color: const Color(0xFFFF5722),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  _steps[_currentStep],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 32, color: Colors.white70),
                    onPressed: () => setState(() => _currentStep--),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _steps.length - 1) {
                      setState(() => _currentStep++);
                    } else {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 80),
                    backgroundColor: const Color(0xFFFF5722),
                  ),
                  child: Text(
                    _currentStep < _steps.length - 1 ? 'NEXT STEP' : 'LUTO NA!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                if (_currentStep > 0) const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
