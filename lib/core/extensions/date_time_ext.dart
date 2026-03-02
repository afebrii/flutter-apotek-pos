import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  /// Format: 26 Des 2025
  String get toFormattedDate {
    return DateFormat('dd MMM yyyy', 'id_ID').format(this);
  }

  /// Format: 26 Desember 2025
  String get toFormattedDateLong {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(this);
  }

  /// Format: 26/12/2025
  String get toShortDate {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format: 14:30
  String get toFormattedTime {
    return DateFormat('HH:mm').format(this);
  }

  /// Format: 14:30:45
  String get toFormattedTimeFull {
    return DateFormat('HH:mm:ss').format(this);
  }

  /// Format: 26 Des 2025 14:30
  String get toFormattedDateTime {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(this);
  }

  /// Format: 2025-12-26
  String get toApiDate {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Format: 2025-12-26T14:30:00
  String get toApiDateTime {
    return toIso8601String();
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get days until this date (negative if past)
  int get daysFromNow {
    final now = DateTime.now();
    final difference = this.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}
