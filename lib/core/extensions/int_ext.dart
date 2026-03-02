import 'package:intl/intl.dart';

extension IntExt on int {
  /// Format number as Indonesian Rupiah currency
  /// Example: 50000 -> Rp 50.000
  String get currencyFormatRp {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  /// Format number with thousand separator
  /// Example: 50000 -> 50.000
  String get thousandFormat {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(this);
  }

  /// Convert to Duration in milliseconds
  Duration get milliseconds => Duration(milliseconds: this);

  /// Convert to Duration in seconds
  Duration get seconds => Duration(seconds: this);

  /// Convert to Duration in minutes
  Duration get minutes => Duration(minutes: this);

  /// Convert to Duration in hours
  Duration get hours => Duration(hours: this);
}
