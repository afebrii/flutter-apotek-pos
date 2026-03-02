import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/responses/shift_model.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';
import '../bloc/shift_state.dart';

class OpenShiftDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const OpenShiftDialog({
    super.key,
    required this.onSuccess,
  });

  @override
  State<OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends State<OpenShiftDialog> {
  final _cashController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final cashText = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cash = double.tryParse(cashText) ?? 0;

    if (cash <= 0) {
      context.showErrorSnackBar('Modal awal harus lebih dari 0');
      return;
    }

    context.read<ShiftBloc>().add(
          ShiftOpen(
            OpenShiftRequest(
              openingCash: cash,
              notes: _notesController.text.isNotEmpty
                  ? _notesController.text
                  : null,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShiftBloc, ShiftState>(
      listener: (context, state) {
        if (state is ShiftOpened) {
          context.showSuccessSnackBar('Shift berhasil dibuka');
          Navigator.pop(context);
          widget.onSuccess();
        } else if (state is ShiftError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SpaceWidth(16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buka Shift',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SpaceHeight(4),
                            Text(
                              'Masukkan modal awal kasir',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(24),

                  // Cash input with thousand separator
                  _buildCashInput(),
                  const SpaceHeight(16),

                  // Notes input
                  CustomTextField(
                    controller: _notesController,
                    label: 'Catatan (Opsional)',
                    hint: 'Contoh: Shift pagi',
                    maxLines: 2,
                    prefixIcon: const Icon(Icons.notes),
                  ),
                  const SpaceHeight(24),

                  // Buttons
                  BlocBuilder<ShiftBloc, ShiftState>(
                    builder: (context, state) {
                      final isLoading = state is ShiftLoading;
                      return Row(
                        children: [
                          Expanded(
                            child: Button.outlined(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              label: 'Batal',
                            ),
                          ),
                          const SpaceWidth(16),
                          Expanded(
                            child: Button.filled(
                              onPressed: isLoading ? null : _onSubmit,
                              label: 'Buka Shift',
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modal Awal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cashController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            _ThousandsSeparatorInputFormatter(),
          ],
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '500.000',
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 16,
            ),
            prefixText: 'Rp  ',
            prefixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            filled: true,
            fillColor: AppColors.white,
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
          ),
        ),
      ],
    );
  }
}

/// Input formatter for thousand separator (Indonesian format: 500.000)
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
