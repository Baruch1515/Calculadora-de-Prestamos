import 'package:intl/intl.dart';

String formatCurrency(String value) {
  final NumberFormat currencyFormat =
      NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  double amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  return currencyFormat.format(amount);
}

String formatPercentage(String value) {
  final NumberFormat percentFormat =
      NumberFormat.decimalPercentPattern(decimalDigits: 0, locale: 'es');
  double percentage =
      double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  return percentFormat.format(percentage / 100);
}
