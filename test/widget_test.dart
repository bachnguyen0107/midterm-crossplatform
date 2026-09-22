import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_crossplatform1/main.dart';

void main() {
  testWidgets('converts 0°C to 32.00 °F', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('inputField')), '0');
    await tester.tap(find.byKey(const Key('convertButton')));
    await tester.pump();

    expect(find.text('32.00 °F'), findsOneWidget);
    expect(find.byKey(const Key('errorText')), findsNothing);
  });

  testWidgets('shows an error when the field is empty', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('convertButton')));
    await tester.pump();

    expect(find.text('Please enter a value'), findsOneWidget);
    expect(find.byKey(const Key('resultText')), findsNothing);
  });

  testWidgets('shows an error for non-numeric input', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('inputField')), 'abc');
    await tester.tap(find.byKey(const Key('convertButton')));
    await tester.pump();

    expect(find.text('Please enter a valid number'), findsOneWidget);
  });

  testWidgets('switches direction and converts Fahrenheit to Celsius',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('directionDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fahrenheit → Celsius').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('inputField')), '212');
    await tester.tap(find.byKey(const Key('convertButton')));
    await tester.pump();

    expect(find.text('100.00 °C'), findsOneWidget);
  });
}