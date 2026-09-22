import 'package:flutter/material.dart';

import 'converter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const ConverterPage(),
    );
  }
}

enum ConversionDirection { celsiusToFahrenheit, fahrenheitToCelsius }

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _controller = TextEditingController();
  ConversionDirection _direction = ConversionDirection.celsiusToFahrenheit;
  String? _resultText;
  String? _errorText;

  void _convert() {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      setState(() {
        _errorText = 'Please enter a value';
        _resultText = null;
      });
      return;
    }

    final value = double.tryParse(input);
    if (value == null) {
      setState(() {
        _errorText = 'Please enter a valid number';
        _resultText = null;
      });
      return;
    }

    final result = _direction == ConversionDirection.celsiusToFahrenheit
        ? celsiusToFahrenheit(value)
        : fahrenheitToCelsius(value);
    final unit =
        _direction == ConversionDirection.celsiusToFahrenheit ? '°F' : '°C';

    setState(() {
      _errorText = null;
      _resultText = '${result.toStringAsFixed(2)} $unit';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temperature Converter')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('inputField'),
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Value'),
            ),
            const SizedBox(height: 16),
            DropdownButton<ConversionDirection>(
              key: const Key('directionDropdown'),
              value: _direction,
              items: const [
                DropdownMenuItem(
                  value: ConversionDirection.celsiusToFahrenheit,
                  child: Text('Celsius → Fahrenheit'),
                ),
                DropdownMenuItem(
                  value: ConversionDirection.fahrenheitToCelsius,
                  child: Text('Fahrenheit → Celsius'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _direction = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('convertButton'),
              onPressed: _convert,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 24),
            if (_errorText != null)
              Text(
                _errorText!,
                key: const Key('errorText'),
                style: const TextStyle(color: Colors.red),
              ),
            if (_resultText != null)
              Text(
                _resultText!,
                key: const Key('resultText'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
          ],
        ),
      ),
    );
  }
}
