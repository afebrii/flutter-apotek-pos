import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  // Screen dimensions
  double get deviceHeight => MediaQuery.of(this).size.height;
  double get deviceWidth => MediaQuery.of(this).size.width;

  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Navigation
  Future<T?> push<T extends Object?>(Widget page) {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page,
  ) {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      MaterialPageRoute(builder: (context) => page),
      predicate,
    );
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.pop<T>(this, result);
  }

  void popToRoot() {
    Navigator.popUntil(this, (route) => route.isFirst);
  }

  // Snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  // Dialog
  Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  // Bottom Sheet
  Future<T?> showCustomBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => child,
    );
  }
}
