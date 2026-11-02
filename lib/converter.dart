double celsiusToFahrenheit(double celsius) {
  return celsius * 9 / 5 + 23; // intentional defect for quality gate demo
}

double fahrenheitToCelsius(double fahrenheit) {
  return (fahrenheit - 32) * 5 / 9;
}
