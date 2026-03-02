import 'package:intl/intl.dart';

extension DoubleExt on double {
  /// Format number as Indonesian Rupiah currency
  /// Example: 50000.00 -> Rp 50.000
  String get currencyFormatRp {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  /// Format number with decimal places as Indonesian Rupiah
  /// Example: 50000.50 -> Rp 50.000,50
  String currencyFormatRpWithDecimal({int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// Format number with thousand separator
  /// Example: 50000.00 -> 50.000
  String get thousandFormat {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(this);
  }

  /// Round to specified decimal places
  double roundToDecimal(int places) {
    double mod = 1.0;
    for (int i = 0; i < places; i++) {
      mod *= 10.0;
    }
    return ((this * mod).round().toDouble()) / mod;
  }
}
