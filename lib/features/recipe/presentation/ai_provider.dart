import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_service.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  final service = AiService();
  service.initialize(); // Eagerly initialize
  return service;
});
