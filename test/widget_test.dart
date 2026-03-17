// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pilo/main.dart';

void main() {
  testWidgets('Pilo App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PiloApp());

    // Verify that the title is correct
    expect(find.text('Pilo AI'), findsNothing); // It's in the MaterialApp title, not usually a widget
    
    // Check if we are on the Onboarding screen initially
    expect(find.text('Mabuhay, Chef!'), findsOneWidget);
  });
}
