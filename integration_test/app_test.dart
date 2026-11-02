import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:midterm_crossplatform1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full flow: C to F, switch direction, F to C, invalid input', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // 1.Celsius to Fahrenheit
    await tester.enterText(find.byKey(const Key('inputField')), '0');
    await tester.tap(find.byKey(const Key('convertButton')));
    await tester.pumpAndSettle();
    expect(find.text('32.00 °F'), findsOneWidget);

    // 2.Open the dropdown and pick F to C
    await tester.tap(find.byKey(const Key('directionDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fahrenheit → Celsius').last);
    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButton<app.ConversionDirection>>(
      find.byKey(const Key('directionDropdown')),
    );
    expect(dropdown.value, app.ConversionDirection.fahrenheitToCelsius);

    // 3.Fahrenheit to Celsius
    await tester.tap(find.byKey(const Key('inputField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('inputField')), '212');
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byKey(const Key('inputField')));
    expect(field.controller!.text, '212');

    await tester.tap(find.byKey(const Key('convertButton')));
    await tester.pumpAndSettle();

    final result = find.byKey(const Key('resultText'));
    if (result.evaluate().isNotEmpty) {
      debugPrint('Result shown: ${tester.widget<Text>(result).data}');
    }
    expect(find.text('100.00 °C'), findsOneWidget);

    // 4.Invalid input
    await tester.tap(find.byKey(const Key('inputField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('inputField')), 'abc');
    await tester.tap(find.byKey(const Key('convertButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid number'), findsOneWidget);
  });
}
