import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


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
          .split(RegExp(r'(?<=^|\n)\s*\d+\.\s*'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (_steps.isEmpty) _steps = ['Follow the recipe instructions!'];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Stop Cooking?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: const Text('Are you sure you want to exit? Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('KEEP COOKING'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('EXIT', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        title: Text(
          'KUSINA MODE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              backgroundColor: Colors.white10,
              color: Theme.of(context).primaryColor,
              minHeight: 6,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(_currentStep),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _steps[_currentStep],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _currentStep--),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.white70),
                        ),
                      ),
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
                      minimumSize: const Size(200, 75),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(
                      _currentStep < _steps.length - 1 ? 'NEXT STEP' : 'LUTO NA!',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  if (_currentStep > 0) const SizedBox(width: 56),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
