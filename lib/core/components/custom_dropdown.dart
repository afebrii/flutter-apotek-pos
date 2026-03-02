import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    this.hint,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          items: items,
          onChanged: enabled ? onChanged : null,
          initialValue: value,
          hint: hint != null
              ? Text(
                  hint!,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 16,
                  ),
                )
              : null,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.grey,
          ),
          decoration: InputDecoration(
            errorText: errorText,
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.greyLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
          ),
        ),
      ],
    );
  }
}
