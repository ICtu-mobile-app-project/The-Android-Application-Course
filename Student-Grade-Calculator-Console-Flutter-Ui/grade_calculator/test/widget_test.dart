// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:grade_calculator/main.dart';

void main() {
  testWidgets('App renders Grade Calculator title', (WidgetTester tester) async {
    await tester.pumpWidget(const GradeCalculatorApp());

    // The home screen should contain the app title in the gradient header.
    expect(find.text('Grade Calculator'), findsOneWidget);
  });
}
