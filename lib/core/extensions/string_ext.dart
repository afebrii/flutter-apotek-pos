extension StringExt on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is valid phone number (Indonesian format)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$');
    return phoneRegex.hasMatch(replaceAll(' ', '').replaceAll('-', ''));
  }

  /// Convert to int or return null
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// Convert to double or return null
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string contains only digits
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);
}
