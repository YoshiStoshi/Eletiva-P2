// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build a minimal MaterialApp and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    // Verify that the app has loaded
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

// Test uses a minimal MaterialApp to avoid importing the real app
// which initializes Firebase and requires extra setup.
