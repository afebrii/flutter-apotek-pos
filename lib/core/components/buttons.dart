import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Button {
  // Primary filled button
  static Widget filled({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    double? width,
    double height = 48,
    Color? color,
    Color? textColor,
    double borderRadius = 8,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Outlined button
  static Widget outlined({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    double? width,
    double height = 48,
    Color? borderColor,
    Color? textColor,
    double borderRadius = 8,
    bool isLoading = false,
  }) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(color: effectiveBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: effectiveTextColor,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Text button
  static Widget text({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    Color? textColor,
    bool isLoading = false,
  }) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor ?? AppColors.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: textColor ?? AppColors.primary),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? AppColors.primary,
                  ),
                ),
              ],
            ),
    );
  }

  // Icon button with background
  static Widget icon({
    required VoidCallback? onPressed,
    required IconData icon,
    Color? backgroundColor,
    Color? iconColor,
    double size = 48,
    double iconSize = 24,
    double borderRadius = 8,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
