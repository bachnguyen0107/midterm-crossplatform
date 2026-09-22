import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_crossplatform1/converter.dart';

void main() {
  group('celsiusToFahrenheit', () {
    test('converts 0°C to 32°F', () {
      expect(celsiusToFahrenheit(0), 32);
    });

    test('converts 100°C to 212°F', () {
      expect(celsiusToFahrenheit(100), 212);
    });

    test('converts negative temperatures', () {
      expect(celsiusToFahrenheit(-40), -40);
    });
  });

  group('fahrenheitToCelsius', () {
    test('converts 32°F to 0°C', () {
      expect(fahrenheitToCelsius(32), 0);
    });

    test('converts 212°F to 100°C', () {
      expect(fahrenheitToCelsius(212), 100);
    });

    test('round trip matches original value', () {
      const original = 36.6;
      final roundTripped =
          fahrenheitToCelsius(celsiusToFahrenheit(original));
      expect(roundTripped, closeTo(original, 0.0001));
    });
  });
}